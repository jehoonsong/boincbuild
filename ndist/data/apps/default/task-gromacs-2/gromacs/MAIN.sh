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

CLEANUP() {
redis-cli SET _counter 1
  echo "Stopping container..."
  docker stop "$CONTAINER_NAME" >/dev/null 2>&1
  docker rm   "$CONTAINER_NAME" >/dev/null 2>&1
}
trap CLEANUP EXIT

echo "0.01" > fraction_done
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

# Extract INPUT.tgz contents
tar xvzf INPUT.tgz -C $tmpr

# Run the Docker container using the temporary directory
CONTAINER_NAME="temp_$(mktemp -u XXXXXX)"
docker run --name $CONTAINER_NAME --rm --pull=always \
	-v /tmp:/tmp -w "$tmpr" ghcr.io/nettargets/gromacs:gmx-2025.2-cuda-12.8 \
	bash run_short.sh

# After Docker execution, collect results into OUTPUT.tgz
tar cvzf OUTPUT.tgz .

# Cleanup (optional)
# rm -rf "$tmpr"

echo "bye!"

redis-cli SET _counter 1

