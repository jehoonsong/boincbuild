#!/bin/bash

datadir=`pwd`

prefix="in-"

echo "prefix:" $prefix

cp $prefix*.tgz /home/boincadm/project/download

cd "$PROJECT_ROOT"

mkdir -p scratch

for inputfile in $(ls download/$prefix*.tgz); do
    echo "Submitting: $inputfile"

    myinput=$(basename "$inputfile")
    echo $myinput

    bin/create_work \
        --appname myapp \
        --wu_template templates/myapp_in \
        --result_template templates/myapp_out \
        "$myinput" > "$datadir/${myinput}_wu"
done
