# Globus TIG
This exec script and it supporting files allow one to ingest Globus GridFTP transfer logs from a machine (or machines) running a Globus GridFTP endpoint. This tool has been tested against both GCSv4 and GCSv5 installations and works for both.  

## Requirements
- This has be built with Python3, make sure that is available
- Install of geoip2 and pygeohash python modules (pip3 install geoip2 pygeohash)
- Need to optain a free copy of MaxMind's GeoLite2-City.mmdb database
	- This can be obtained for free
	- Create a free account at: https://maxmind.com
	- Download Page URL will look something like: https://www.maxmind.com/en/accounts/current/geoip/downloads
	- Make sure you get the "GeoLite2 City" database (NOT in .csv format, but .mmdb)
	- Place this file in the /etc/telegraf/globus/ directory with the rest of this repo's contents
- This code will support logs timestamped in either RFC3164 and RFC5424

## Deployment
- Place all contents of this repo in /etc/telegraf/globus/
- Configure an exec check in Telegraf to execute the gridftp_log_parse.sh script once per minute (60 seconds)
	- Setting this frequency is important for the check to work properly given how it is configured
