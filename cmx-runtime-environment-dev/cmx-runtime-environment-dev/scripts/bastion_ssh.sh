#!/bin/bash

HELP="Usage: bastion_ssh.sh [OPTIONS] \n \
				Options: \n \
					-i|--ingress\t\t\t\tConnect to the ingress VPC bastion host \n \
					-k|--k8s\t\t\t\tConnect to the bastion in kubernetes (cluster bastion) \n \
					-p|--profile <application profile>\tUse a profile besides the one specified in CMX_APPLICATION_PROFILE ${CMX_APPLICATION_PROFILE} \
					\n"

# Parse command-line arguments
INGRESS=0
K8S=0
CMX_ENV="$CMX_APPLICATION_PROFILE"
while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
	    -i|--ingress)
	     INGRESS=1; shift # past argument
	    ;;
			-k|--k8s)
			 K8S=1; shift; # past argument
			;;
	    -p|--profile)
	     CMX_ENV="$2"; shift; shift # past argument/value
	    ;;
			-h|--help)
			 echo -e $HELP
			 exit
			;;
	esac
done

if [ "$CMX_ENV" != "" ]; then
  source ~/.codametrix/$CMX_ENV/bastion_settings
else
  echo "No application profile supplied"
  exit
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $SCRIPT_DIR/utility/ssh_utils.sh

# check bastion username
if [[ ! $bastion_username ]]; then
  read_required_input bastion_username 'bastion username'
fi

# check bastion key
if [[ ! $bastion_key ]]; then
  read_required_input bastion_key 'bastion ssh key path'
fi
bastion_key_secret=$(derive_bastion_secret_from_bastion_key $bastion_key)

#check bastion address
if [[ $INGRESS -gt 0 ]]; then
  if [[ ! $ingress_bastion_address ]]; then
    read_required_input ingress_bastion_address 'ingress bastion address'
  fi
else
  if [[ ! $bastion_address ]]; then
    read_required_input bastion_address 'bastion address'
  fi
fi

ADDRESS=$bastion_address
if [[ $INGRESS -gt 0 ]]; then
  ADDRESS=$ingress_bastion_address
fi

CLUSTER_ADDRESS=""
if [[ $K8S -gt 0 ]]; then
	# check cluster bastion address
	if [[ $INGRESS -gt 0 ]]; then
	  if [[ ! $ingress_cluster_bastion_address ]]; then
	    read_required_input ingress_cluster_bastion_address 'ingress cluster bastion address'
	  fi
	else
	  if [[ ! $cluster_bastion_address ]]; then
	    read_required_input cluster_bastion_address 'cluster bastion address'
	  fi
	fi

	CLUSTER_ADDRESS=$cluster_bastion_address
	if [[ $INGRESS -gt 0 ]]; then
	  CLUSTER_ADDRESS=$ingress_cluster_bastion_address
	fi
fi

if [[ $K8S -eq 0 ]]; then
  echo "SSH to bastion host in the $CMX_ENV environment with following parameters:"
else
	echo "SSH to cluster bastion in the $CMX_ENV environment with following parameters:"
fi
echo "Bastion username: $bastion_username"
echo "Bastion key: $bastion_key"
echo "Bastion address: $ADDRESS"

if [[ $K8S -eq 0 ]]; then
	echo ""

	set -x
  ssh -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null" -i $bastion_key $bastion_username@$ADDRESS
else
	echo "Cluster bastion address: $CLUSTER_ADDRESS"
	echo ""

	set -x
	ssh -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null" -i $bastion_key $bastion_username@$ADDRESS ssh -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null" -i /home/$bastion_username/.ssh/cluster_bastion_id_rsa $bastion_username@$CLUSTER_ADDRESS
fi
set +x
