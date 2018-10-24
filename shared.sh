#!/bin/bash

set -e

cd $(dirname $0)

if [ -z $TRAVIS_TAG ]
then
	echo "Missing TRAVIS_TAG env var" >> /dev/stderr
        exit 1
fi 

IMAGE_NAME=oleconsignado/otc-vsts-agent
IMAGE_TAG=docker-$DOCKER_VERSION-kubectl-$KUBECTL_VERSION-helm-$HELM_VERSION-$TRAVIS_TAG
IMAGE_FULL_NAME=$IMAGE_NAME:$IMAGE_TAG

if [ -z $DOCKER_USERNAME ] || [ -z $DOCKER_PASSWORD ]
then
	echo "Missing DOCKER_USERNAME and/or DOCKER_PASSWORD env vars" >> /dev/stderr
	exit 1
fi

echo "Performing login to Dockerhub ..."
docker login -u "$DOCKER_USERNAME" -p "$DOCKER_PASSWORD"

echo "Building image ..."
docker build --build-arg KUBECTL_VERSION=$KUBECTL_VERSION --build-arg DOCKER_VERSION=$DOCKER_VERSION  . -t $IMAGE_FULL_NAME

echo "Pushing image ..."
docker push $IMAGE_FULL_NAME


