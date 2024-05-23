#!/bin/bash

usage() { echo "Usage: $0 [-h <localhost>] [-p <8443>] -r repository_name" 1>&2; exit 1; }

host='localhost'
port='8443'

while getopts ":h:p:r:" opt; do
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
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

echo host:$host port:$port repo_name:$repo

curl -k -X GET "https://$host:$port/_cat/snapshots/$repo"
