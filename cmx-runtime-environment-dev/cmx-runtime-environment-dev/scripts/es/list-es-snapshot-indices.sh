#!/bin/bash

usage() { echo "Usage: $0 [-h <localhost>] [-p <8443>] -r repository_name -s snapshot_name" 1>&2; exit 1; }

host='localhost'
port='8443'

if ! command -v jq &> /dev/null
then
    echo "jq could not be found. Please install it"
    exit
fi


while getopts ":h:p:r:s:" opt; do
    case ${opt} in
        h)
            host=${OPTARG}
            ;;
        p)
            port=${OPTARG}
            ;;
        r)
            repo=${OPTARG}
            ;;
        s)
            snap=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

echo host:$host port:$port repo_name:$repo snapshot:$snap

curl -k -X GET "https://$host:$port/_snapshot/$repo/$snap" | jq
