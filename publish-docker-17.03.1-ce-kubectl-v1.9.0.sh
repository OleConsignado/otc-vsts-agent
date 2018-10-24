#!/bin/bash

set -e 

# Get latest stable kubectl version: curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt
KUBECTL_VERSION=v1.9.0
DOCKER_VERSION=17.03.1-ce

source $(dirname $0)/shared.sh

