# 베이스 이미지 설정
FROM ubuntu:24.04

RUN sed -i 's|http://archive.ubuntu.com|http://mirror.kakao.com|g; s|http://security.ubuntu.com|http://mirror.kakao.com|g' /etc/apt/sources.list && \
    apt-get update

# 필요한 환경 변수 설정
ENV DEBIAN_FRONTEND=noninteractive

# 필요한 패키지 설치
RUN apt-get install -y software-properties-common && \
    add-apt-repository --remove ppa:costamagnagianfranco/boinc && \
    apt-get update && \
    apt-get install -y boinc

# BOINC 클라이언트 디렉토리 권한 설정
RUN mkdir -p /var/lib/boinc-client && \
    useradd -r -d /var/lib/boinc-client boincadm && \
    chown -R boincadm:boincadm /var/lib/boinc-client

WORKDIR /var/lib/boinc-client

USER root 

# BOINC 클라이언트 디렉토리 권한 설정
RUN touch /var/lib/boinc-client/gui_rpc_auth.cfg && \
    chown boincadm:boincadm /var/lib/boinc-client/gui_rpc_auth.cfg && \
    chmod 600 /var/lib/boinc-client/gui_rpc_auth.cfg

USER root 


# CMD ["boinc", "--dir", "/var/lib/boinc-client", "--attach_project", "http://localhost:80/hello", "75ef880d8aba41af5e36db5b1f19e220"]

# boinc --attach_project http://127.0.0.1/hello 75ef880d8aba41af5e36db5b1f19e220

# RUN apt install -y telnet ping

RUN apt-get update && \
    apt-get install -y net-tools iputils-ping telnet curl


# CMD boinc --dir /var/lib/boinc-client --attach_project http://localhost:80/hello 75ef880d8aba41af5e36db5b1f19e220
