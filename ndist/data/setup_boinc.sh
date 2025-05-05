cp -vr /data/myapp /home/boincadm/project/apps/
cp -vr /data/templates/* /home/boincadm/project/templates/
cp -v /data/app_config.xml /home/boincadm/project/app_config.xml

crontab -l 2>/dev/null | grep -q "bin/start --cron" || \
(crontab -l 2>/dev/null; echo "*/5 * * * * cd /home/boincadm/project && bin/start --cron") | crontab -

chown boincadm:boincadm -Rv /home/boincadm/project/upload
chown boincadm:boincadm -Rv /home/boincadm/project/download
chown boincadm:boincadm -Rv /home/boincadm/project/*
cp project.xml /home/boincadm/project 
cd /home/boincadm/project && bin/xadd 
cd /home/boincadm/project && bin/update_versions

