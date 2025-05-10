#!/usr/bin/env bash

# If INPUT.tgz contains a <soft_link> tag, extract the linked file
if grep -q '<soft_link>' INPUT.tgz; then
	TEXT=$(grep -oP '(?<=<soft_link>).*?(?=</soft_link>)' INPUT.tgz)
	cp "$TEXT" ./
fi

tar xvzf INPUT.tgz

if [[ -f "./MAIN.sh" ]]; then
	bash MAIN.sh  
else
  echo "error: MAIN.sh not found"
fi

# After Docker execution, collect results into OUTPUT.tgz
tar cvzf OUTPUT.tgz .

echo "bye!"

