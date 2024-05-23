#!/bin/bash

docker pull alpine
docker build --no-cache -t cmx-java-service-base -f ./Dockerfile ./
