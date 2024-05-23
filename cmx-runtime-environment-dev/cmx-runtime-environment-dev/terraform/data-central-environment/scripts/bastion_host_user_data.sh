#!/bin/bash
set -o xtrace

if ! [ -x "$(command -v curl)" ]; then
   sudo apt -y install curl
fi
curl -O https://inspector-agent.amazonaws.com/linux/latest/install
chmod 777 install
sudo bash install
sudo /etc/init.d/awsagent start