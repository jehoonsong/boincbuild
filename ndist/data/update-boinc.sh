
cp -vr /data/myapp /home/boincadm/project/apps/
cp -vr /data/templates/* /home/boincadm/project/templates/
#cp -v /data/app_config.xml /home/boincadm/project/app_config.xml

crontab -l 2>/dev/null | grep -q "bin/start --cron" || \
(crontab -l 2>/dev/null; echo "*/5 * * * * cd /home/boincadm/project && bin/start --cron") | crontab -

cp project.xml /home/boincadm/project 
cp config.xml /home/boincadm/project 

chown boincadm:boincadm -Rv /home/boincadm/project/*

chmod 644 /home/boincadm/project/project.xml
chmod 644 /home/boincadm/project/config.xml

chmod 755 /home/boincadm/project/upload
chmod 755 /home/boincadm/project/download

cd /home/boincadm/project && chown -R boincadm:boincadm upload
cd /home/boincadm/project && usermod -aG boincadm www-data
cd /home/boincadm/project && chmod g+ws upload
cd /home/boincadm/project && chmod g+ws download

#rm -rf $PROJECT_ROOT/download/*

cd /home/boincadm/project && bin/xadd 
cd /home/boincadm/project && bin/update_versions

cd /data && bash fixpermissions.sh 
