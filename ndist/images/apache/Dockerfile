FROM boinc/server_apache:4.0.1-b2d

COPY sources.list /etc/apt/sources.list

RUN apt-get update && apt-get install -y \
    vim

RUN apt-get install -y python-pip && \
    pip install ipdb ipython

RUN apt-get update && apt-get install -y \
    iputils-ping nano rsync make zip unzip

ENV DOCKER_API_VERSION=1.24

# overwrite 
COPY makeproject-step3.sh /usr/bin/

RUN apt-get update && apt-get install -y \
	boinc

#RUN apt update && apt install python3 python3-pip -y
#RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1
#RUN apt install pipx -y
#RUN pipx ensurepath

# Install build dependencies
RUN apt update && apt install -y \
    wget build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev curl libncursesw5-dev \
    xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

# Install Python 3.10
RUN cd /usr/src && \
    wget https://www.python.org/ftp/python/3.10.13/Python-3.10.13.tgz && \
    tar xzf Python-3.10.13.tgz && \
    cd Python-3.10.13 && \
    ./configure --enable-optimizations && \
    make -j$(nproc) && \
    make altinstall

# Set default python3 → 3.10
RUN update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.10 1

# Install pip3 for Python 3.10
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10

# Install pipx via python3.10
RUN python3.10 -m pip install --no-cache-dir pipx && \
    python3.10 -m pipx ensurepath && \
    ln -s /root/.local/bin/pipx /usr/local/bin/pipx



# RUN pipx install vastai

ENV PATH="$HOME/.local/bin:$PATH"
