#!/bin/bash

# Configure memory
CONTAINER_MEMORY=4GB

docker run --rm -it -m $CONTAINER_MEMORY \
	cmx-java-service-base
