
FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04

SHELL ["/bin/bash", "-c"]

ARG USER_ID=1000
ARG USER_GID=$USER_ID
ARG USER_NAME=ubuntu
ARG PASSWORD=ubuntu

RUN if id -u $USER_ID ; then userdel `id -un $USER_ID`; fi 

RUN groupadd --gid $USER_GID $USER_NAME && \
    useradd --uid $USER_ID --gid $USER_GID -m $USER_NAME && \
    apt-get update && \
    apt-get install -y sudo && \
    echo $USER_NAME:$PASSWORD | chpasswd && \
    echo "$USER_NAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
WORKDIR /home/$USER_NAME
ENV TERM=xterm-256color

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo

# setup timezone
RUN echo 'Asia/Tokyo' > /etc/timezone && \
    ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    apt-get update && DEBIAN_FRONTEND=noninteractive && \
    apt-get install -q -y --no-install-recommends \
        tzdata && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# setup environment
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# locale
RUN apt-get update && DEBIAN_FRONTEND=noninteractive && \
    apt-get install -q -y --no-install-recommends \
        locales && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
RUN locale-gen en_US.UTF-8

# install basic packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    x11-apps \
    mesa-utils \
    apt-utils \
    net-tools \
    curl \
    lsb-release \
    command-not-found \
    git \
    vim \
    wget \
    gnupg2 \
    build-essential \
    xdg-utils \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    libreadline-dev \
    libncursesw5-dev \
    libssl-dev \
    libsqlite3-dev \
    libgdbm-dev \
    libbz2-dev \
    liblzma-dev \
    zlib1g-dev \
    uuid-dev \
    libffi-dev \
    libdb-dev \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget --no-check-certificate https://www.python.org/ftp/python/3.9.5/Python-3.9.5.tgz \
    && tar -xf Python-3.9.5.tgz \
    && cd Python-3.9.5 \
    && ./configure --enable-optimizations\
    && make \
    && make install

RUN apt-get autoremove -y

USER $USER_NAME
WORKDIR /home/$USER_NAME

RUN cd && git clone https://github.com/motional/nuplan-devkit.git

RUN echo 'export NUPLAN_DATA_ROOT="$HOME/nuplan/dataset"' >> ~/.bashrc && \
    echo 'export NUPLAN_MAPS_ROOT="$HOME/nuplan/dataset/maps"' >> ~/.bashrc && \
    echo 'export NUPLAN_EXP_ROOT="$HOME/nuplan/exp"' >> ~/.bashrc

COPY requirements_torch.txt /home/$USER_NAME/nuplan-devkit/requirements_torch.txt

RUN cd nuplan-devkit && \
    pip3 install -e . && \
    pip3 install -r requirements_torch.txt && \
    pip3 install -r requirements.txt

ENV NVIDIA_VISIBLE_DEVICES ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

CMD ["bash"]