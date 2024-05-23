#!/bin/bash


HELP="Usage: bastion_proxy.sh [OPTIONS] \n \
				Options: \n \
					-p|--profile <application profile>\tUse a profile besides the one specified in CMX_APPLICATION_PROFILE ${CMX_APPLICATION_PROFILE}\
					\n"

# Fun Random Number Generator function
RANDOM=`date "+%s"`
random_port=$(($RANDOM%50))
base=10000
let port_number=$random_port+$base
echo $port_number


# Parse command-line arguments
INGRESS=0
CMX_ENV="$CMX_APPLICATION_PROFILE"
while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
	    -i|--ingress)
	     INGRESS=1; shift # past argument/value
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

# check bastion username
if [[ ! $bastion_username ]]; then
  read_required_input bastion_username 'bastion username'
fi

# check bastion key path
if [[ ! $bastion_key ]]; then
  read_required_input bastion_key 'basion ssh key path'
fi
bastion_key_secret=$(derive_bastion_secret_from_bastion_key $bastion_key)

# check bation host address
if [[ ! $bastion_address ]]; then
  read_required_input bastion_address 'bastion address'
fi
ADDRESS=$bastion_address

echo "Creating tunnel with following parameters:"
echo "bastion username: $bastion_username"
echo "Bastion key: $bastion_key"
echo "Bastion address: $ADDRESS"

echo "ssh -i $bastion_key $bastion_username@$ADDRESS -ND $port_number"
echo "Your assigned port number is $port_number"

set -x
ssh -i $bastion_key $bastion_username@$ADDRESS -ND $port_number
