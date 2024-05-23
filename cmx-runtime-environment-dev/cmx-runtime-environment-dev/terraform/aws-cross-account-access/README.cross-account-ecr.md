Follow steps from: https://medium.com/media-iq-tech/cross-account-how-to-access-aws-container-registry-service-from-another-aws-account-using-iam-b372796ede14

... didn't need to do step 4, as the trusted policy for our EKS node instance role
already had the ability to assume role.

On the Kubernetes front, need to create the ecr-docker-login cronjob to update the docker repo and credentials.
