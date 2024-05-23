#! /bin/bash

HELP="Usage: awsudo.sh [OPTIONS] \n \
				Options: \n \
					-p|--profile <AWS profile>\tUse a specific AWS profile \
					\n"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $SCRIPT_DIR/utility/cmx_utils.sh

# Parse command-line arguments
AWS_PROFILE=""
STD_PARAMS=""
while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
	    -p|--profile)
	     AWS_PROFILE="$2"; shift; shift # past argument/value
	    ;;
			-h|--help)
			 echo -e $HELP
			 exit
			;;
      *)
        STD_PARAMS="$STD_PARAMS $1"; shift
	esac
done

# Parse the AWS credentials file
ini.parser ~/.aws/credentials
ini.section."$AWS_PROFILE"
export AWS_ACCESS_KEY_ID=$aws_access_key_id
export AWS_SECRET_ACCESS_KEY=$aws_secret_access_key
export AWS_SESSION_TOKEN=$aws_session_token
export AWS_SECURITY_TOKEN=$aws_security_token

eval $STD_PARAMS
