#!/bin/bash
set -e
set -x

echo "### Performing final clean-up tasks ###"
# Remove SSH authorized keys
rm /home/ubuntu/.ssh/authorized_keys
# Clear out /etc/resolv.conf
sudo cp /dev/null /etc/resolv.conf
