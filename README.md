# Globus TIG
This exec script and it supporting files allow one to ingest Globus GridFTP transfer logs from a machine (or machines) running a Globus GridFTP endpoint. This tool has been tested against both GCSv4 and GCSv5 installations and works for both.  

## Deployment
- Place all contents of this repo in /etc/telegraf/ directory (merge contents of telegraf.d/ with your existing files if applicable)
- Fill in globus_config file with relevant info

NOTE: Setting the frequency of this check as outlined (once per minute) is important for the check to work properly given how it is configured
