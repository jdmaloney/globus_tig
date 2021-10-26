#!/bin/bash

tfile=$(mktemp /tmp/gridftplog.XXXXXX)
source /etc/telegraf/globus/globus_config

##Telegraf compatible exec script to parse the Globus Log on the localhost
##This it intended to be run with an interval of 60 seconds

## Get any log lines from past 60 seconds and chunk it to only what we need
date_filter=$(date +'%a %b %d %H:%M:.. %Y' -d -1minute)
cat ${log} | cut -d' ' -f 2- | grep "${date_filter}" | sed -e 's/.*DATE=\(.*\) HOST=\(.*\) PROG.*\sUSER=\(.*\) FILE.*BUFFER=\(.*\) BLOCK.*\sNBYTES=\(.*\) VOLUME.*\sDEST=\[\(.*\)] TYPE=\(.*\) CODE.*$/\1 \2 \3 \4 \5 \6 \7/' > ${tfile}
## Parse last 60 seconds of log
while read l; do
	fields=($(echo ${l}))
	if [[ ${fields[5]} =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                        ## Convert IP to Gehash and timestamp to correct format, cached geohash to improve speed if same IP is sequential ##
                        if [ -z ${geohash} ] || [ ${ip} != ${fields[5]} ]; then
                                geohash=$(python3 /etc/telegraf/globus/ip2geohash.py ${fields[5]})
				if [ -z ${geohash} ]; then
					geohash=dp1k0q6encpx
				fi
                        fi
                        realtime=$(echo ${fields[0]} | sed -e 's/./&:/12;s/./&:/10;s/./& /8;s/./&-/6;s/./&-/4')
                        timestamp=$(date --date="${realtime}UTC" +%s%N)
			ip=${fields[5]}
			echo "transfer,endpoint=\"${endpoint}\",user=${fields[2]},geohash=${geohash},host=${fields[1]},type=${fields[6]} bytes=${fields[4]},buffer=${fields[3]},metric=1 ${timestamp}"
	fi
done < ${tfile}
rm -rf ${tfile}
