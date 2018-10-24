# Ref: https://github.com/microsoft/vsts-agent-docker/blob/d9c72fb5d961e37843d8dd0274fb5346022d6852/ubuntu/16.04/standard/Dockerfile

FROM microsoft/vsts-agent:ubuntu-16.04

ARG KUBECTL_VERSION
ARG DOCKER_VERSION
ARG HELM_VERSION

# Install basic command-line utilities
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    curl \
    dnsutils \
    file \
    ftp \
    iproute2 \
    iputils-ping \
    locales \
    openssh-client \
    rsync\
    shellcheck \
    sudo \
    telnet \
    time \
    unzip \
    wget \
    zip \
    tzdata \
 && rm -rf /var/lib/apt/lists/*

# Setup the locale
ENV LANG en_US.UTF-8
ENV LC_ALL $LANG
RUN locale-gen $LANG \
 && update-locale

# Install .NET Core SDK and initialize package cache
RUN curl https://packages.microsoft.com/config/ubuntu/16.04/packages-microsoft-prod.deb > packages-microsoft-prod.deb \
 && dpkg -i packages-microsoft-prod.deb \
 && rm packages-microsoft-prod.deb \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
    apt-transport-https \
    dotnet-sdk-2.1 \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /etc/apt/sources.list.d/*
RUN dotnet help
ENV dotnet=/usr/bin/dotnet

# Install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl \
 && chmod +x ./kubectl \
 && mv ./kubectl /usr/local/bin/kubectl

# Install Helm
RUN mkdir helm-installation \
  && cd helm-installation \
  && curl https://storage.googleapis.com/kubernetes-helm/helm-$HELM_VERSION-linux-amd64.tar.gz -o helm.tar.gz \
  && tar xfvz helm.tar.gz \
  && cp linux-amd64/helm /usr/local/bin \
  && cd ..  \
  && rm -Rf helm-installation \
  && chmod a+x /usr/local/bin/helm

# Docker
ENV DOCKER_CHANNEL stable

RUN set -ex \
 && curl -fL "https://download.docker.com/linux/static/${DOCKER_CHANNEL}/`uname -m`/docker-$DOCKER_VERSION.tgz" -o docker.tgz \
 && tar --extract --file docker.tgz --strip-components 1 --directory /usr/local/bin \
 && rm docker.tgz \
 && docker -v

# Clean system
RUN apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /etc/apt/sources.list.d/*    

