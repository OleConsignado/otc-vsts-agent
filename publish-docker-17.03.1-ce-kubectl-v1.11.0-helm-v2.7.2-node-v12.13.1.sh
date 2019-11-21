#!/bin/bash

set -e 

HELM_VERSION=v2.7.2
# Get latest stable kubectl version: curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt
KUBECTL_VERSION=v1.11.0
DOCKER_VERSION=17.03.1-ce
NODE_VERSION=v12.13.1

source $(dirname $0)/shared.sh

