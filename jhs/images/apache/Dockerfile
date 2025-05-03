FROM boinc/server_apache:4.0.1-b2d

COPY sources.list /etc/apt/sources.list

RUN apt-get update && apt-get install -y \
    vim
RUN apt-get install -y python-pip && \
    pip install ipdb ipython

RUN apt-get update && apt-get install -y \
    iputils-ping nano

ENV DOCKER_API_VERSION=1.24

# overwrite 
COPY makeproject-step3.sh /usr/bin/

