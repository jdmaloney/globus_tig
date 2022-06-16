# Globus TIG
This exec script and it supporting files allow one to ingest Globus GridFTP transfer logs from a machine (or machines) running a Globus GridFTP endpoint. This tool has been tested against both GCSv4 and GCSv5 installations and works for both.  

## Deployment
- Place all contents of this repo in /etc/telegraf/globus/
- Fill in globus_config file with relevant info
- Configure an exec check in Telegraf to execute the gridftp_log_parse.sh script once per minute (60 seconds)
	- Setting this frequency is important for the check to work properly given how it is configured
