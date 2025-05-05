cd $PROJECT_ROOT

mkdir -p scratch

for i in $(seq 1 5); do
  echo ${i}
  bin/create_work --appname myapp --wu_template templates/myapp_in --result_template templates/myapp_out groinput-111-${i}.tgz > scratch/groworkunit-${i}
done
