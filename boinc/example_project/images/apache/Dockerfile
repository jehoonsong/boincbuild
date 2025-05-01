# 베이스 이미지 설정
FROM ubuntu:24.04

RUN sed -i 's|http://archive.ubuntu.com|http://mirror.kakao.com|g; s|http://security.ubuntu.com|http://mirror.kakao.com|g' /etc/apt/sources.list && \
    apt-get update

# 필요한 환경 변수 설정
ENV DEBIAN_FRONTEND=noninteractive

# 필요한 패키지 설치
RUN apt-get update && apt upgrade -y 

RUN apt-get -y install git \
    default-mysql-server \
    libmysqlclient-dev \
    apache2 \
    autoconf \
    pkg-config \
    libtool \
    libcurl4-openssl-dev \
    python3-pip \
    python3-mysqldb \
    python-is-python3 \
    libapache2-mod-php \
    php-mysql \
    php-cli \
    php-gd \
    php-xml \
    build-essential \
    automake \
    m4 \
    libtool-bin \
    autopoint \
    gettext

# boincadm 사용자 추가 및 작업 디렉토리 설정
RUN useradd -m boincadm && mkdir -p /home/boincadm

WORKDIR /home/boincadm

# Configure apache 
RUN usermod -a -G boincadm www-data && \
    a2enmod cgi

COPY 1.4.7.tar.gz .

RUN tar -xzf 1.4.7.tar.gz && \
    rm 1.4.7.tar.gz

WORKDIR /home/boincadm/boinc-server_release-1.4-1.4.7

# BOINC 설치
RUN ./_autosetup
RUN ./configure --disable-manager --enable-apps --disable-samples
RUN make 
RUN make -i install 

ENV PROMPT_COMMAND='history -a'

RUN apt update && \
    apt install nano -y 

RUN echo "boincadm ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

ENV USER=boincadm
USER boincadm

# WORKDIR /home/boincadm/boinc-server_release-1.4-1.4.7/tools
WORKDIR /home/boincadm/

ENV PATH=/home/boincadm/boinc-server_release-1.4-1.4.7/tools:$PATH

USER root 

# Install cron
RUN apt-get update && apt-get install -y cron && \
    service cron start

# Install Python 2.7 from source
RUN apt-get update && apt-get install -y \
    build-essential \
    zlib1g-dev \
    libncurses5-dev \
    libgdbm-dev \
    libnss3-dev \
    libssl-dev \
    libreadline-dev \
    libffi-dev \
    libsqlite3-dev \
    wget \
    libbz2-dev && \
    wget https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tgz && \
    tar xzf Python-2.7.18.tgz && \
    cd Python-2.7.18 && \
    ./configure --enable-optimizations && \
    make altinstall && \
    cd .. && \
    rm -rf Python-2.7.18* && \
    ln -sf /usr/local/bin/python2.7 /usr/bin/python2 && \
    wget https://bootstrap.pypa.io/pip/2.7/get-pip.py && \
    python2 get-pip.py && \
    rm get-pip.py

# Apache 포트를 외부에 노출
EXPOSE 80


## --- 
# 필요한 패키지 설치
# RUN apt-get install -y software-properties-common && \
#     add-apt-repository --remove ppa:costamagnagianfranco/boinc && \
#     apt-get update && \
#     apt-get install -y boinc
# BOINC 클라이언트 디렉토리 권한 설정
RUN mkdir -p /var/lib/boinc-client && \
    # useradd -r -d /var/lib/boinc-client boincadm && \
    chown -R boincadm:boincadm /var/lib/boinc-client
WORKDIR /var/lib/boinc-client
USER root 
# BOINC 클라이언트 디렉토리 권한 설정   
RUN touch /var/lib/boinc-client/gui_rpc_auth.cfg && \
    chown boincadm:boincadm /var/lib/boinc-client/gui_rpc_auth.cfg && \
    chmod 600 /var/lib/boinc-client/gui_rpc_auth.cfg
## --- 

WORKDIR /projects

# ENTRYPOINT ["/setup.sh"]
# docker-compose build && docker run -it --rm example_project_apache bash 
# docker build . -t test && docker run --rm -it -v $(pwd)/bash_history:/root/.bash_history test bash 

# Apache를 포그라운드에서 실행
# CMD ["apache2ctl", "-D", "FOREGROUND"]
COPY setup.sh /setup.sh

RUN chmod +x /setup.sh
