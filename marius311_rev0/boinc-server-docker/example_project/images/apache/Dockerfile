FROM boinc/server_apache:4.0.1-b2d

COPY sources.list /etc/apt/sources.list

RUN apt-get update && apt-get install -y \
    vim
RUN apt-get install -y python-pip && \
    pip install ipdb ipython

ENV DOCKER_API_VERSION=1.24

