#!/bin/bash

taskdir=`pwd`
echo "taskdir: $taskdir"

prefix="$1"

echo "press ENTER key to continue ..."

read

echo "prefix:" $prefix

cp $prefix*.tgz $PROJECT_ROOT/download
cp tmpl_* $PROJECT_ROOT/templates

cd "$PROJECT_ROOT"

mkdir -p scratch

for inputfile in $(ls download/$prefix*.tgz); do
    echo "Submitting: $inputfile"
    myinput=$(basename "$inputfile")
    bin/create_work --appname default --wu_template templates/tmpl_in --result_template templates/tmpl_out \
        "$myinput" > "$taskdir/${myinput}_wu"
done

