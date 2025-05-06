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

cat $appdir/version.xml

cat > $PROJECT_ROOT/app_info.xml<<EOL
<app_info>
    <app>
        <name>myapp</name>
    </app>

    <file_info>
        <name>myapp_${version}_x86_64-pc-linux-gnu</name>
        <executable/>
    </file_info>

    <app_version>
        <app_name>myapp</app_name>
        <version_num>${version}</version_num>
        <platform>x86_64-pc-linux-gnu</platform>
        <file_ref>
            <file_name>myapp_${version}_x86_64-pc-linux-gnu</file_name>
            <main_program/>
        </file_ref>
        <max_concurrent>1</max_concurrent> 
    </app_version>
</app_info>
EOL

cat $PROJECT_ROOT/app_info.xml
