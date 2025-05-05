#!/bin/bash

# dd if=/dev/zero of=1mb_file bs=1M count=1

if grep -q '<soft_link>' INPUT.tgz; then
    TEXT=$(grep -oP '(?<=<soft_link>).*?(?=</soft_link>)' INPUT.tgz) && cp $TEXT ./
fi

tar xzf INPUT.tgz 

if [ -f "MAIN.sh" ]; then
    bash MAIN.sh 
fi

sleep 30

tar czf OUTPUT.tgz ./

exit 0