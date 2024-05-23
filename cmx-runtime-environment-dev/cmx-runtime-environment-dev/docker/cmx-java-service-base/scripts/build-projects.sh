#!/bin/bash

# This script expects the following environment variable(s):
# PROJECTS_DIR (path to working directory where projects live)
# BUILD_PROJECTS (comma separated list of projects to build)

# List of projects to build should be passed in on the command line as a
# comma separated list

# Iterate through build projects and do a maven install of each one
cd $PROJECTS_DIR
BUILD_PROJECTS=$(tr , " " <<< $@)
for PROJECT in $BUILD_PROJECTS; do
	echo "Building:" $PROJECT
	pushd $PROJECT
  mvn clean
	mvn install
	popd
done
