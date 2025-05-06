#!/usr/bin/env bash

# Create a temporary working directory under /tmp
tmpr=$(mktemp -d -p /tmp tmpdata.XXXXXX)
echo "Working in temporary directory: $tmpr"

# If INPUT.tgz contains a <soft_link> tag, extract the linked file
if grep -q '<soft_link>' INPUT.tgz; then
    TEXT=$(grep -oP '(?<=<soft_link>).*?(?=</soft_link>)' INPUT.tgz)
    cp "$TEXT" ./
fi

# Extract INPUT.tgz contents
tar xvzf INPUT.tgz -C $tmpr

# Run the Docker container using the temporary directory
docker run --rm -v /tmp:/tmp -w "$tmpr" ghcr.io/nettargets/gromacs:gmx-2025.2-cuda-12.8 \
	bash run.sh

# After Docker execution, collect results into OUTPUT.tgz
tar cvzf OUTPUT.tgz .

# Cleanup (optional)
# rm -rf "$tmpr"

echo "bye!"
