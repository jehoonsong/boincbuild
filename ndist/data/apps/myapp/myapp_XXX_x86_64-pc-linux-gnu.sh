#!/usr/bin/env bash

KEY="_counter"
REDIS_CLI="redis-cli"

LUA_SCRIPT='
local v = redis.call("GET", KEYS[1])
if not v then
	redis.call("SET", KEYS[1], 0)
	return 1
end
local num = tonumber(v)
if num > 0 then
	redis.call("SET", KEYS[1], 0)
	return 1
else
	return 0
end
'

while true; do
	result=$($REDIS_CLI EVAL "$LUA_SCRIPT" 1 $KEY)

	if [ "$result" -eq 1 ]; then
		echo "[INFO] $KEY was nil or > 0 → set to 0 and exiting loop"
		break
	else
		echo "[INFO] $KEY is 0 → still looping..."
		sleep 10
	fi
done

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
docker run --rm --pull=always -v /tmp:/tmp -w "$tmpr" ghcr.io/nettargets/gromacs:gmx-2025.2-cuda-12.8 \
	bash run.sh

# After Docker execution, collect results into OUTPUT.tgz
tar cvzf OUTPUT.tgz .

# Cleanup (optional)
# rm -rf "$tmpr"

echo "bye!"

redis-cli SET _counter 1

