#!/bin/bash

# Configure the GUI RPC
echo $BOINC_GUI_RPC_PASSWORD > /var/lib/boinc/gui_rpc_auth.cfg
echo $BOINC_REMOTE_HOST > /var/lib/boinc/remote_hosts.cfg

crontab -l 2>/dev/null | grep -q "boinccmd" || \
    (crontab -l 2>/dev/null; echo "*/5 * * * * boinccmd --project $BOINC_PROJECT_URL update") | crontab -

service cron start
# service cron status

# Run BOINC. Full path needs for GPU support.
exec /usr/bin/boinc $BOINC_CMD_LINE_OPTIONS

