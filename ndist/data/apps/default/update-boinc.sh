version=$1
echo "version: $version"

read 

cp -vr $version /home/boincadm/project/apps/default
# cp -vr /data/templates/* /home/boincadm/project/templates/

cd /home/boincadm/project && bin/xadd 
cd /home/boincadm/project && bin/update_versions
