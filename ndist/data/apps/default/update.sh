#!/bin/bash

# ls default

version=$1 
echo "version:" $version

read

appdir=$version/x86_64-pc-linux-gnu
mkdir -p $appdir

cp -v wrapper_XXX_x86_64-pc-linux-gnu $appdir/wrapper_${version}_x86_64-pc-linux-gnu
cp -v default_job_XXX.xml $appdir/default_job_$version.xml
cp -v default_XXX_x86_64-pc-linux-gnu.sh $appdir/default_${version}_x86_64-pc-linux-gnu.sh

cat > $appdir/version.xml<<EOL
<version>
  <file>
    <physical_name>wrapper_${version}_x86_64-pc-linux-gnu</physical_name>
    <main_program/>
  </file>
  <file>
    <physical_name>default_${version}_x86_64-pc-linux-gnu.sh</physical_name>
    <logical_name>default</logical_name>
  </file>
  <file>
    <physical_name>default_job_${version}.xml</physical_name>
    <logical_name>job.xml</logical_name>
  </file>
</version>
EOL

cat > app_info.xml<<EOL
<app_info>
    <app>
        <name>default</name>
    </app>

    <file_info>
        <name>default_${version}_x86_64-pc-linux-gnu</name>
        <executable/>
    </file_info>

    <app_version>
        <app_name>default</app_name>
        <version_num>${version}</version_num>
        <platform>x86_64-pc-linux-gnu</platform>
        <file_ref>
            <file_name>default_${version}_x86_64-pc-linux-gnu</file_name>
            <main_program/>
        </file_ref>
        <max_concurrent>1</max_concurrent> 
    </app_version>
</app_info>
EOL
