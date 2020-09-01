# Ref: https://github.com/microsoft/vsts-agent-docker/blob/d9c72fb5d961e37843d8dd0274fb5346022d6852/ubuntu/16.04/standard/Dockerfile

FROM microsoft/vsts-agent:ubuntu-16.04

ARG KUBECTL_VERSION
ARG DOCKER_VERSION
ARG HELM_VERSION
ARG NODE_VERSION

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
    xz-utils \
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
    dotnet-sdk-2.2 \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /etc/apt/sources.list.d/*
RUN dotnet help
ENV dotnet=/usr/bin/dotnet

# Install Java OpenJDKs
RUN apt-add-repository -y ppa:openjdk-r/ppa
RUN apt-get update \
 && apt-get install -y --no-install-recommends openjdk-8-jdk \
 && rm -rf /var/lib/apt/lists/*
RUN apt-get update \
 && apt-get install -y --no-install-recommends openjdk-11-jdk \
 && rm -rf /var/lib/apt/lists/*
ENV JAVA_HOME_8_X64=/usr/lib/jvm/java-8-openjdk-amd64 \
    JAVA_HOME_11_X64=/usr/lib/jvm/java-11-openjdk-amd64

# Set default jdk
#RUN update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java
RUN update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-11-openjdk-amd64/bin/java 1102
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 \
    JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF8

# Install Java Tools (Ant, Gradle, Maven)
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    ant \
    ant-optional \
 && rm -rf /var/lib/apt/lists/*
RUN curl -sL https://services.gradle.org/distributions/gradle-4.6-bin.zip -o gradle-4.6.zip \
 && unzip -d /usr/share gradle-4.6.zip \
 && ln -s /usr/share/gradle-4.6/bin/gradle /usr/bin/gradle \
 && rm gradle-4.6.zip
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    maven \
 && rm -rf /var/lib/apt/lists/*
ENV ANT_HOME=/usr/share/ant \
    GRADLE_HOME=/usr/share/gradle \
    M2_HOME=/usr/share/maven

# Install Google Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
 && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | tee /etc/apt/sources.list.d/google-chrome.list \
 && apt-get update \
 && apt-get install -y google-chrome-stable \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /etc/apt/sources.list.d/*
ENV CHROME_BIN /usr/bin/google-chrome

# Install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl \
 && chmod +x ./kubectl \
 && mv ./kubectl /usr/local/bin/kubectl

# Install Helm
RUN mkdir helm-installation \
  && cd helm-installation \
  && curl https://storage.googleapis.com/kubernetes-helm/helm-$HELM_VERSION-linux-amd64.tar.gz -o helm.tar.gz \
  && tar xfvz helm.tar.gz \
  && cp linux-amd64/helm /usr/local/bin/ \
  && cd ..  \
  && rm -Rf helm-installation \
  && chmod a+x /usr/local/bin/helm

# Install Node
RUN curl https://nodejs.org/dist/$NODE_VERSION/node-$NODE_VERSION-linux-x64.tar.xz -o node-$NODE_VERSION-linux-x64.tar.xz \
  && mkdir /usr/local/lib/nodejs \
  && tar -xJvf node-$NODE_VERSION-linux-x64.tar.xz -C /usr/local/lib/nodejs \
  && rm node-$NODE_VERSION-linux-x64.tar.xz \
  && ln -s /usr/local/lib/nodejs/node-$NODE_VERSION-linux-x64/bin/node /usr/bin/node \
  && ln -s /usr/local/lib/nodejs/node-$NODE_VERSION-linux-x64/bin/npm /usr/bin/npm \
  && ln -s /usr/local/lib/nodejs/node-$NODE_VERSION-linux-x64/bin/npx /usr/bin/npx

# Docker
ENV DOCKER_CHANNEL stable

RUN set -ex \
 && curl -fL "https://download.docker.com/linux/static/${DOCKER_CHANNEL}/`uname -m`/docker-$DOCKER_VERSION.tgz" -o docker.tgz \
 && tar --extract --file docker.tgz --strip-components 1 --directory /usr/local/bin \
 && rm docker.tgz \
 && docker -v

# Instala ferramenta para analize de cobertura de testes (coverlet)
RUN dotnet tool install --global coverlet.console --version 1.5.3
# Sonarscanner para integracao com sonarqube
RUN dotnet tool install --global dotnet-sonarscanner --version 4.6.2

# Instala ferramenta otc-task
COPY otc-task /usr/local/bin/
COPY otc-task-include /usr/local/bin/
RUN chmod a+x /usr/local/bin/otc-task
RUN chmod a+x /usr/local/bin/otc-task-include

# Clean system
RUN apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /etc/apt/sources.list.d/*    

