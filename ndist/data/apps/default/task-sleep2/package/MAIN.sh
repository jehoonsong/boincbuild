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

TOTAL_DURATION=60

PROGRESS_FILE="fraction_done"

echo 0.0 > "$PROGRESS_FILE"

START_TIME=$(date +%s)

while true; do
  CURRENT_TIME=$(date +%s)
  ELAPSED=$((CURRENT_TIME - START_TIME))

  FRACTION=$(awk -v e="$ELAPSED" -v t="$TOTAL_DURATION" 'BEGIN { f=e/t; if(f>1) f=1; printf "%.4f\n", f }')

  echo "$FRACTION" > "$PROGRESS_FILE"

  if (( ELAPSED >= TOTAL_DURATION )); then
    break
  fi
  sleep 5

done

echo "bye!"

redis-cli SET _counter 1

