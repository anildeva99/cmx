#! /usr/bin/env bash

DIR=$(dirname $0)
BASENAME=$(basename -s .sh $0)

registryId="643073444324"
profile=${1:-default}
manifest=${2:-$DIR/$BASENAME.manifest}

#
# For each pod, use kubectl to get its info, in JSON format, parsing
# it with jq.  For the containers within the pod which match the name
# of the pod (i.e. providing the "service" of that pod), if the
# container has the expected version tag, parse its K8s SHA256
# digest. There may be more than one container in the pod with a
# matching name, but only one of those may match the expected version
# tag. Compare the K8s digest to that of the image in the AWS ECR
# registry. Display the status, one line per pod.
#
for pod in $(kubectl get pods -o jsonpath="{.items[*].metadata.name}"); do
    for service in $(kubectl get pods -o json $pod | tee /tmp/$pod.json | jq -r '.status.containerStatuses[]["name"]'); do

        if [[ $pod =~ .*$service.* ]]; then
            # Get info for service from manifest
            versioninfo=$(sed -n "/$service/p" $manifest)
            regex=$(awk '{print $2}' <<<$versioninfo)
            imageTag=$(awk '{print $3}' <<<$versioninfo)

            # Use jq regex to find container image in the pod jSON
            image=""
            if [ "$regex" != "" ]; then
                image=$(jq -r --arg regex .*$regex.* '.status.containerStatuses[]["imageID"] | match($regex) | .string' < /tmp/$pod.json)
            fi

            # if image found...
            if [ "$image" != ""  ]; then
                # SHA256 digest of K8s container
                path=$(awk -F: '{print $2}' <<<$image | sed 's/\/\///g;s/@sha256//g')
                k8sSHA=$(awk -F: '{print $3}' <<<$image)

                # SHA256 digest of ECR container image with matching version
                repo=$(awk -F/ '{print $2}' <<<$path)
                ecrSHA=$(aws --profile $profile ecr describe-images \
                             --filter tagStatus=TAGGED --registry-id $registryId --repository-name $repo \
                            | jq -r --arg imageTag $imageTag '.imageDetails[] | select(.imageTags[] | contains($imageTag))' \
                            | jq -r '.imageDigest' | sed 's/sha256://g')

                # Digests should match
                if [ "$ecrSHA" == "$k8sSHA" ]; then shaStatus="OK"; else shaStatus="MISMATCH"; fi
                echo -e "$pod $path $imageTag $k8sSHA $ecrSHA $shaStatus"
            fi
        fi
    done
done
