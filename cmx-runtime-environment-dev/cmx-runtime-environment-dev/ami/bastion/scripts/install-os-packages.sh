#!/bin/bash -x
set -e
set -x

# Add additional OS packages
packages="apt-transport-https \
					binutils \
					ca-certificates \
					curl \
					htop \
					jq \
					nfs-common \
          parallel \
					python-pip \
					python3-pip \
					software-properties-common \
          screen \
					tree \
					unzip \
          wget"

pip_packages="awscli \
							botocore \
							boto3"

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
sudo pip3 install $pip_packages
