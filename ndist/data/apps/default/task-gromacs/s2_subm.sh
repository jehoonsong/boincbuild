#!/bin/bash

datadir=`pwd`

prefix="$1"

echo "check if input prefix is correct: $prefix"
echo "press ENTER key to continue ..."
read

cp $prefix*.tgz $PROJECT_ROOT/download

cd "$PROJECT_ROOT"

mkdir -p scratch

for inputfile in $(ls download/$prefix*.tgz); do
    echo "Submitting: $inputfile"

    myinput=$(basename "$inputfile")
    echo $myinput

    bin/create_work \
        --appname default --wu_template templates/myapp_in_maxcpu --result_template templates/myapp_out \
        "$myinput" > "$datadir/${myinput}_wu"
done

