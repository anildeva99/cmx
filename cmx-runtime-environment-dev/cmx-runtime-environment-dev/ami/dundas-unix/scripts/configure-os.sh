#!/bin/bash -x
set -e
set -x

#Updates
sudo apt-get -y update
sudo apt-get -y upgrade

#Custom Tools
sudo apt-get install -y liblttng-ust0 \
          apt-transport-https \
					binutils \
					ca-certificates \
					curl \
					htop \
					jq \
					nfs-common \
          openssh-server \
          parallel \
					python-pip \
					software-properties-common \
          screen \
					tree \
					unzip \
          wget

#Install AWS CLI
sudo -H pip install awscli
#Create directory for aws config file
mkdir /home/ubuntu/.aws/
