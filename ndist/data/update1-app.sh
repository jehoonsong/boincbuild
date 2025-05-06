#!/bin/bash

ls myapp

version=$1 
echo "version:" $version
read

appdir=myapp/$version/x86_64-pc-linux-gnu
mkdir -p $appdir

cp -v wrapper_XXX_x86_64-pc-linux-gnu $appdir/wrapper_${version}_x86_64-pc-linux-gnu
cp -v myapp_job_XXX.xml $appdir/myapp_job_$version.xml
cp -v myapp_XXX_x86_64-pc-linux-gnu.sh $appdir/myapp_${version}_x86_64-pc-linux-gnu.sh

cat > $appdir/version.xml <<EOL
<version>
  <file>
    <physical_name>wrapper_${version}_x86_64-pc-linux-gnu</physical_name>
    <main_program/>
  </file>
  <file>
    <physical_name>myapp_${version}_x86_64-pc-linux-gnu.sh</physical_name>
    <logical_name>myapp</logical_name>
  </file>
  <file>
    <physical_name>myapp_job_${version}.xml</physical_name>
    <logical_name>job.xml</logical_name>
  </file>
</version>
EOL
