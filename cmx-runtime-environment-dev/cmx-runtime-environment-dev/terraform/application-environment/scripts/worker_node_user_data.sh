#!/bin/bash
set -o xtrace

# Create an IPtables rule so that containers running on the workers which make instance metadata requests
# will have those requests forwarded to the kube2iam container running on each node (DaemonSet)
# !!! Note, below we're referencing eni+ (regex) host interfaces, because I believe
# !!! AWS configures /dev/eniXXXXXXX interfaces for each cluster container. Need
# !!! to verify that.
# See documentation here: https://github.com/jtblin/kube2iam
iptables \
  --append PREROUTING \
  --protocol tcp \
  --destination 169.254.169.254 \
  --dport 80 \
  --in-interface eni+ \
  --jump DNAT \
  --table nat \
  --to-destination `curl 169.254.169.254/latest/meta-data/local-ipv4`:8181

# Bootstrap EKS
/etc/eks/bootstrap.sh ${ClusterName} ${BootstrapArguments}

# Install AWS Inspector agent
if ! [ -x "$(command -v curl)" ]; then
   sudo apt -y install curl
fi
curl -O https://inspector-agent.amazonaws.com/linux/latest/install
chmod 777 install
sudo bash install
sudo /etc/init.d/awsagent start