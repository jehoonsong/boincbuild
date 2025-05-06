#!/usr/bin/env bash

if grep -q '<soft_link>' INPUT.tgz; then
    TEXT=$(grep -oP '(?<=<soft_link>).*?(?=</soft_link>)' INPUT.tgz) && cp $TEXT ./
fi

# ok
tar cvzf OUTPUT.tgz .

#ok 
echo "run docker..."
docker run --rm ubuntu ls

echo "run gromacs docker ... ls /"
docker run --rm -v /tmp:/tmp -w $tmpr ghcr.io/nettargets/gromacs:gmx-2025.2-cuda-12.8 ls / 

echo "run gromacs docker ... ls"
docker run --rm -v /tmp:/tmp -w $tmpr ghcr.io/nettargets/gromacs:gmx-2025.2-cuda-12.8 ls 

echo "run gromacs docker ... find /"
docker run --rm -v /tmp:/tmp -w $tmpr ghcr.io/nettargets/gromacs:gmx-2025.2-cuda-12.8 find /

echo "bye!"
