#!/bin/bash

tfile=$(mktemp /tmp/gridftplog.XXXXXX)
source /etc/telegraf/globus/globus_config

##Telegraf compatible exec script to parse the Globus Log on the localhost
##This it intended to be run with an interval of 60 seconds

## Get any log lines from past 60 seconds and chunk it to only what we need
is_iso=$(tail -n 1 ${log} | awk '{print $2}' | grep "-")
if [ -n "${is_iso}" ]; then
	## Log uses RFC 5424 format timestamps
	date_filter=$(date +'%Y-%m-%dT%H:%M' -d -1minute)
else
	## Log uses RFC 3164 format timestamps
	date_filter=$(date +'%a %b %e %H:%M:.. %Y' -d -1minute)
fi
cat ${log} | cut -d' ' -f 2- | grep "${date_filter}" | sed -e 's/.*DATE=\(.*\) HOST=\(.*\) PROG.*\sUSER=\(.*\) FILE.*BUFFER=\(.*\) BLOCK.*\sNBYTES=\(.*\) VOLUME.*\sDEST=\[\(.*\)] TYPE=\(.*\) CODE.*$/\1 \2 \3 \4 \5 \6 \7/' > ${tfile}
## Parse last 60 seconds of log
while read l; do
	fields=($(echo ${l}))
	if [[ ${fields[5]} =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                        ## Convert IP to Lat/Long, cache results if IP same as prior log line
			if [ -z ${latitude} ] || [ ${ip} != ${fields[5]} ]; then
                                IFS="," read -r success latitude longitude org < <(curl http://ip-api.com/csv/${fields[5]} 2> /dev/null | cut -d',' -f 1,8,9,11)
                                if [ ${success} != "success" ]; then
                                        latitude="${default_lat}"
                                        longitude="${default_long}"
					organization="Not\ Found"
				else
					organization=$(echo "${org_raw}" | sed 's/\ /\\ /g')
				fi
			fi
			organization=$(echo \""${org}"\" | sed 's/\ /\\ /g')
			realtime=$(echo ${fields[0]} | sed -e 's/./&:/12;s/./&:/10;s/./& /8;s/./&-/6;s/./&-/4')
                        timestamp=$(date --date="${realtime}UTC" +%s%N)
			ip=${fields[5]}
			echo "transfer,endpoint=${endpoint},user=${fields[2]},src_dest_org=\"${organization}\",type=${fields[6]} latitude=${latitude},longitude=${longitude},bytes=${fields[4]},buffer=${fields[3]},files=1 ${timestamp}"
	fi
done < ${tfile}
rm -rf ${tfile}
