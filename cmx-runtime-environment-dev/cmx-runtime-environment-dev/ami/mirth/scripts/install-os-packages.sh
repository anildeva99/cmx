#!/bin/bash -x
set -e
set -x

# Add additional OS packages
packages="apt-transport-https \
					binutils \
					ca-certificates \
					curl \
					gnupg-agent \
					htop \
					jq \
					nfs-common \
          parallel \
					python-pip \
					software-properties-common \
          screen \
					tree \
					unzip \
          wget"

# Adding this line to enable us to install jq
sudo apt-add-repository "deb http://us.archive.ubuntu.com/ubuntu bionic main universe"

sudo add-apt-repository universe
sudo apt-get -y update
sudo apt-mark hold grub-pc
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o DPkg::options::="--force-confdef" -o DPkg::options::="--force-confold" upgrade

echo "### Installing additional packages: $packages ###"
for package in $packages; do
  sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o DPkg::options::="--force-confdef" -o DPkg::options::="--force-confold" install $package
done

# Add AWSCLI via pip
sudo pip install awscli

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get -y update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o DPkg::options::="--force-confdef" -o DPkg::options::="--force-confold" install docker-ce docker-ce-cli containerd.io
