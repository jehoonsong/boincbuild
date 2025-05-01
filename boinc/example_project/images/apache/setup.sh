#!/bin/bash

project_name=hello

srcdir=/home/boincadm/boinc-server_release-1.4-1.4.7
projdir=/projects/$project_name

# 1. create project
cd $srcdir/tools

./make_project --db_passwd password --url_base http://127.0.0.1 --db_host mysql --db_user root \
    --delete_prev_inst --drop_db_first --no_query --project_root /projects/$project_name $project_name

mysql -u root -h mysql -ppassword -e "INSERT IGNORE INTO \`user\` VALUES (1,1746065856,'jehoon.song@net-targets.com','jhs','75ef880d8aba41af5e36db5b1f19e220','None','',0,0,1746065856,NULL,'',0,'',NULL,1,1,0,0,0,0,0,NULL,0,'eb021b141222b338f5176b28466fd8bf','$2y$10$hF6niZ//s926mMxgPWCgEuTXnkorck3Z/8Lb6ht7fp4FsVgfPH.V.',0,0,'',0,'',0);" $project_name

# 2. setup apache
cd $projdir
cp hello.httpd.conf /etc/apache2/sites-enabled
# apache2ctl restart


# cp -r /apps/* /projects/$project_name/apps/

cat <<EOL > /projects/$project_name/templates/myapp_in
<input_template>
    <file_info>
        <number>0</number>
    </file_info>
    <workunit>
        <file_ref>
            <file_number>0</file_number>
            <open_name>in</open_name>
        </file_ref>
        <command_line>-cpu_time 30</command_line>
    </workunit>
</input_template>
EOL

cat <<EOL > /projects/$project_name/templates/myapp_out
<?xml version="1.0"?>
<output_template>
  <file_info>
    <name><OUTFILE_0/>.tgz</name>
    <generated_locally/>
    <upload_when_present/>
    <max_nbytes>134217728</max_nbytes> <!-- 100Mb -->
    <url><UPLOAD_URL/></url>
  </file_info>
  <result>
    <file_ref>
      <file_name><OUTFILE_0/>.tgz</file_name>
      <open_name>results.tgz</open_name>
      <copy_file>1</copy_file>
    </file_ref>
  </result>
</output_template>
EOL

cat <<EOL > /projects/$project_name/project.xml 
<boinc>
    <platform>
        <name>windows_intelx86</name>
        <user_friendly_name>Microsoft Windows (98 or later) running on an Intel x86-compatible CPU</user_friendly_name>
    </platform>
    <platform>
        <name>windows_x86_64</name>
        <user_friendly_name>Microsoft Windows running on an AMD x86_64 or Intel EM64T CPU</user_friendly_name>
    </platform>
    <platform>
        <name>i686-pc-linux-gnu</name>
        <user_friendly_name>Linux running on an Intel x86-compatible CPU</user_friendly_name>
    </platform>
    <platform>
        <name>x86_64-pc-linux-gnu</name>
        <user_friendly_name>Linux running on an AMD x86_64 or Intel EM64T CPU</user_friendly_name>
    </platform>
    <platform>
        <name>powerpc-apple-darwin</name>
        <user_friendly_name>Mac OS X 10.3 or later running on Motorola PowerPC</user_friendly_name>
    </platform>
    <platform>
        <name>i686-apple-darwin</name>
        <user_friendly_name>Mac OS 10.4 or later running on Intel</user_friendly_name>
    </platform>
    <platform>
        <name>x86_64-apple-darwin</name>
        <user_friendly_name>Intel 64-bit Mac OS 10.5 or later</user_friendly_name>
    </platform>
    <platform>
        <name>arm64-apple-darwin</name>
        <user_friendly_name>Mac OS running on ARM</user_friendly_name>
    </platform>
    <platform>
        <name>sparc-sun-solaris2.7</name>
        <user_friendly_name>Solaris 2.7 running on a SPARC-compatible CPU</user_friendly_name>
    </platform>
    <platform>
        <name>sparc-sun-solaris</name>
        <user_friendly_name>Solaris 2.8 or later running on a SPARC-compatible CPU</user_friendly_name>
    </platform>
    <platform>
        <name>sparc64-sun-solaris</name>
        <user_friendly_name>Solaris 2.8 or later running on a SPARC 64-bit CPU</user_friendly_name>
    </platform>
    <platform>
        <name>powerpc64-ps3-linux-gnu</name>
        <user_friendly_name>Sony Playstation 3 running Linux</user_friendly_name>
    </platform>
    <platform>
        <name>aarch64-unknown-linux-gnu</name>
        <user_friendly_name>Linux running on ARM64</user_friendly_name>
    </platform>
    <app>
        <name>myapp</name>
        <user_friendly_name>myapp</user_friendly_name>
    </app>
</boinc>
EOL

echo "hello" > /projects/$project_name/download/input.txt

# app 
myappdir=/projects/hello/apps/myapp/1.0/x86_64-pc-linux-gnu
mkdir -p $myappdir
cat <<EOL > $myappdir/myapp_1.0_x86_64-pc-linux-gnu
#!/bin/bash
echo "Hello BOINC World"
touch .finished
touch results.tgz
exit 0
EOL
chmod +x $myappdir/myapp_1.0_x86_64-pc-linux-gnu

bin/xadd && 
bin/update_versions 

if ! grep -q "ServerName localhost" /etc/apache2/apache2.conf; then
    echo "ServerName localhost" >> /etc/apache2/apache2.conf
fi

echo "ServerName localhost" >> /etc/apache2/apache2.conf

# /home/boincadm/boinc-server_release-1.4-1.4.7/sched/start
# apache2ctl -D FOREGROUND
apache2ctl restart

# 3. setup cron
echo "0,5,10,15,20,25,30,35,40,45,50,55 * * * * cd /projects/hello; python2 bin/start --cron" >> /etc/crontab


cd /projects/$project_name && \
    bin/create_work --appname myapp --wu_template templates/myapp_in --result_template templates/myapp_out input.txt 


sleep 1

# boinc --dir /var/lib/boinc-client --detach_project http://127.0.0.1/hello
# boinc --dir /var/lib/boinc-client --attach_project http://127.0.0.1/hello 75ef880d8aba41af5e36db5b1f19e220
