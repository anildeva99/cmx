#!/bin/bash

HELP="Usage: bastion_tunnel.sh [OPTIONS] \n \
				Options: \n \
					-e|--experimental\t\t\tUse kubefwd to connect to pod in kubernetes rather than the cluster-bastion \n \
					-i|--ingress\t\t\t\tConnect to the ingress VPC \n \
					-k|--k8s\t\t\t\tTunnel to a service in kubernetes \n \
					-p|--profile <application profile>\tUse a profile besides the one specified in CMX_APPLICATION_PROFILE ${CMX_APPLICATION_PROFILE}\
					\n"

# Parse command-line arguments
INGRESS=0
K8S=0
EXPERIMENTAL=0
CMX_ENV="$CMX_APPLICATION_PROFILE"
while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
			-e|--experimental)
			 EXPERIMENTAL=1; shift; # past argument
			;;
	    -i|--ingress)
	     INGRESS=1; shift; # past argument
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
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $SCRIPT_DIR/utility/ssh_utils.sh

if [[ ! $bastion_username ]]; then
  read_required_input bastion_username 'bastion username'
fi

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

# Experimental feature: use kubectl to port-forward instead of cluster bastion
AWS_PROFILE=""
KUBECTL_CONTEXT=""
if [[ $EXPERIMENTAL -gt 0 ]]; then
	K8S=0
	if [[ $INGRESS -gt 0 ]]; then
		kubectl_context=$ingress_kubectl_context
	fi

	if [[ ! $aws_credentials_profile ]]; then
		read_required_input aws_credentials_profile 'AWS credentials profile'
	fi
	if [[ $INGRESS -gt 0 ]]; then
		if [[ ! $ingress_kubectl_context ]]; then
			read_required_input ingress_kubectl_context 'kubectl context'
		fi
	else
		if [[ ! $kubectl_context ]]; then
			read_required_input kubectl_context 'kubectl context'
		fi
  fi

	if [[ ! $kubectl_namespace ]]; then
		read_required_input kubectl_namespace 'kubectl namespace'
	fi

	AWS_PROFILE=$aws_credentials_profile
	KUBECTL_CONTEXT=$kubectl_context
	if [[ $INGRESS -gt 0 ]]; then
	  KUBECTL_CONTEXT=$ingress_kubectl_context
	fi
	KUBECTL_NAMESPACE=$kubectl_namespace
fi

echo "Enter remote address (the address you ultimately want to connect to): "
read remote_address

if [[ ($EXPERIMENTAL -eq 0) && ($K8S -eq 0) && ($remote_address != *"."*) && ("$CMX_ENV" != "") ]]; then
	export remote_address="$remote_address.$CMX_ENV.application.codametrix.com"
	echo "Using: " $remote_address
	echo " "
elif [[ ($EXPERIMENTAL -eq 0) &&  ($K8S -gt 0) && ($remote_address != *"."*) ]]; then
	export remote_address="$remote_address.codametrix"
	echo "Using: " $remote_address
	echo " "
elif [[  ($EXPERIMENTAL -eq 1) ]]; then
  export remote_address="service/$remote_address"
	echo "Using: " $remote_address
	echo " "
fi

echo "Enter local listening port (the port you will use locally): "
read local_port

echo "Enter remote port (the port you ultimately want to connect to): "
read remote_port

echo ""
echo "Creating tunnel to the " $CMX_ENV " environment with following parameters:"
echo "Bastion username: $bastion_username"
echo "Bastion key: $bastion_key"
echo "Bastion address: $ADDRESS"
echo "Local port: $local_port"
echo "Remote port: $remote_port"
echo "Remote address: $remote_address"

if [[ ($EXPERIMENTAL -eq 0) && ($K8S -eq 0) ]]; then
	echo ""
  set -x
  ssh -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null" -i $bastion_key -N -L localhost:$local_port:$remote_address:$remote_port $bastion_username@$ADDRESS
elif [[ ($EXPERIMENTAL -eq 0) && ($K8S -eq 1) ]]; then
	echo "Cluster bastion address: $CLUSTER_ADDRESS"
	echo ""

	# Select random port to use for the tunnel between the bastion and cluster bastion
	bastion_port=$RANDOM

	set -x
	ssh -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null" -i $bastion_key -L localhost:$local_port:localhost:$bastion_port $bastion_username@$ADDRESS ssh -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null" -i /home/$bastion_username/.ssh/cluster_bastion_id_rsa -N -L localhost:$bastion_port:$remote_address:$remote_port $bastion_username@$CLUSTER_ADDRESS
	set +x
	echo "Cleaning up tunnel"
	TERMINATE_COMMAND="for pid in \$(ps -C ssh x | grep \"$bastion_username\" | grep \"$remote_address\" | awk '{print \$1}'); do kill -KILL \$pid; done"
	set -x
	ssh -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null" -i $bastion_key $bastion_username@$ADDRESS $TERMINATE_COMMAND
elif [[ $EXPERIMENTAL -eq 1 ]]; then
	echo "AWS Profile: $AWS_PROFILE"
	echo "Kubectl Context: $KUBECTL_CONTEXT"
	echo "Kubectl Namespace: $KUBECTL_NAMESPACE"

	# Make sure the user is authenticated with AWS so they can do kubectl port forwarding
	aws-mfa --profile $AWS_PROFILE
	$SCRIPT_DIR/awsudo.sh -p $AWS_PROFILE kubectl port-forward --context="$KUBECTL_CONTEXT" --namespace="$KUBECTL_NAMESPACE" $remote_address $local_port:$remote_port
fi
set +x
