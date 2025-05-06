#!/usr/bin/env bash

if grep -q '<soft_link>' INPUT.tgz; then
    TEXT=$(grep -oP '(?<=<soft_link>).*?(?=</soft_link>)' INPUT.tgz) && cp $TEXT ./
fi

tar cvzf OUTPUT.tgz .

echo "bye!"
