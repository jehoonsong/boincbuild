#!/usr/bin/env bash

# [Optional] Example of running GROMACS container with current directory bind-mounted
# docker run -it --rm -w /data -v `pwd`:/data gromacs/gromacs:gmx-2022.2-cuda-11.6.0-avx2 bash
# Use "-c run.sh" to run a script automatically

# Root path for shared volume
#
# Create a temporary directory under the shared root
tmpr=$(mktemp -d -p /tmp tmpdata.XXXXXX)
echo $tmpr

# Copy input archive to the temporary directory and extract it
echo "run: rsync -av --progress . $tmpr"
rsync -av --progress . $tmpr

echo "ls $tmpr"
ls $tmpr

# Run GROMACS container
echo "run docker ..."
docker run -it --rm -v /tmp:/tmp -w $tmpr ghcr.io/nettargets/gromacs:gmx-2025.2-cuda-12.8 ls 

echo "run: rsync -av --progress $tmpr/ `pwd`"
rsync -av --progress $tmpr/ `pwd`

# Optionally clean up the temporary directory after job completes
# rm -rf $tmpr

echo "bye!! (MAIN.sh)"
