#!/usr/bin/env bash

timestamp=$(date +%Y%m%d-%H%M%S)

for i in $(seq 1 10); do
	  cp input.tgz in-${timestamp}-${i}.tgz
done
