#!/usr/bin/env bash

#sudo apt install redis 
#service redis-server start

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

CLEANUP() {
  redis-cli SET _counter 1
  echo "Stopping container..."
  docker stop "$CONTAINER_NAME" >/dev/null 2>&1
  docker rm   "$CONTAINER_NAME" >/dev/null 2>&1
  kill "$monitor_pid" 2>/dev/null
  wait "$monitor_pid" 2>/dev/null
}
trap CLEANUP EXIT INT TERM

if [ "$1" == "debug" ]; then
  echo "debug mode"
else
  while true; do
    if ! result=$($REDIS_CLI EVAL "$LUA_SCRIPT" 1 "$KEY" 2>/dev/null); then
      break
    fi
    result=$($REDIS_CLI EVAL "$LUA_SCRIPT" 1 $KEY)
    if [ "$result" -eq 1 ]; then
      echo "[INFO] $KEY was nil or > 0 → set to 0 and exiting loop"
      break
    else
      echo "[INFO] $KEY is 0 → still looping..."
      sleep 10
    fi
  done
fi 

# Create a temporary working directory under /tmp
tmpr=$(mktemp -d -p /tmp tmpdata.XXXXXX)
echo "Working in temporary directory: $tmpr"

# Extract INPUT.tgz contents
tar xvzf INPUT.tgz -C $tmpr

WATCH_DIR=$tmpr
MAX_SIZE_MB=600
OUTPUT_FILE="fraction_done"
monitor_size() {
  while true; do
    size=$(du -sm "$WATCH_DIR" | awk '{print $1}')
    fraction=$(awk -v s="$size" -v m="$MAX_SIZE_MB" 'BEGIN {
      f = s/m; if (f > 1) f = 1; printf "%.3f", f
    }')
    echo "$fraction" > "$OUTPUT_FILE"
    sleep 5
  done
}
monitor_size &
monitor_pid=$!

# Run the Docker container using the temporary directory
CONTAINER_NAME="temp_$(mktemp -u XXXXXX)"
docker run --name $CONTAINER_NAME --gpus all --rm --pull=always \
	-v /tmp:/tmp -w "$tmpr" ghcr.io/nettargets/gromacs:gmx-2025.2-cuda-12.8 bash run_short.sh

# After Docker execution, collect results into OUTPUT.tgz
mkdir gromacs && cp -r $tmpr/* gromacs/
tar cvzf OUTPUT.tgz .

# Cleanup (optional)
# rm -rf "$tmpr"

echo "bye!"

if [ "$1" == "debug" ]; then
  echo "program end with debug mode"
else
  redis-cli SET _counter 1
fi

