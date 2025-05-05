#!/bin/bash

apt update && apt install -y bc

# 가장 큰 버전 번호를 찾기 위해 myapp 디렉토리의 하위 폴더를 확인합니다.
max_version=0

# myapp 디렉토리 내의 하위 폴더를 순회합니다.
for dir in myapp/*/; do
    # 디렉토리 이름에서 버전 번호를 추출합니다.
    version=$(basename "$dir")
    
    # 버전 번호가 숫자인지 확인하고, 최대 버전 번호를 갱신합니다.
    if [[ $version =~ ^[0-9]+(\.[0-9]+)*$ ]]; then
        if (( $(echo "$version > $max_version" | bc -l) )); then
            max_version=$version
        fi
    fi
done

echo "가장 큰 버전 번호는 $max_version 입니다."

# 0.1 증가 (소수 연산)
new_version=$(awk -v v="$max_version" 'BEGIN {printf "%.1f", v+0.1}')

echo "새 버전: $new_version"

# 새로운 버전 번호를 사용하여 이전 파일들을 우선 복사합니다. 
cp -rv myapp/$max_version myapp/$new_version

cd myapp/$new_version/aarch64-unknown-linux-gnu

mv -v myapp_${max_version}_aarch64-unknown-linux-gnu.sh myapp_${new_version}_aarch64-unknown-linux-gnu.sh
mv -v myapp_job_${max_version}.xml myapp_job_${new_version}.xml
mv -v wrapper_${max_version}_aarch64-unknown-linux-gnu wrapper_${new_version}_aarch64-unknown-linux-gnu

# cat version.xml
# version.xml 내부 버전 문자열 변경
perl -pi -e 's/${max_version}/${new_version}/g' version.xml
