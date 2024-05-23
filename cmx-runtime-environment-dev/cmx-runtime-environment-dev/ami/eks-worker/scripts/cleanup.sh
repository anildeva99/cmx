#!/bin/bash
set -e
set -x

echo "### Performing final clean-up tasks ###"
# Remove SSH authorized keys
rm /home/ec2-user/.ssh/authorized_keys
# Clear out /etc/resolv.conf
sudo cp /dev/null /etc/resolv.conf
