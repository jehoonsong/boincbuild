#!/usr/bin/env bash

if grep -q '<soft_link>' INPUT.tgz; then
    TEXT=$(grep -oP '(?<=<soft_link>).*?(?=</soft_link>)' INPUT.tgz) && cp $TEXT ./
fi

# ok
tar cvzf OUTPUT.tgz .

echo "run docker..."
docker run --rm ubuntu ls

echo "bye!"
