# Codametrix Runtime environment EKS Worker Node AMI
## This project builds an AMI to be used in the application runtime environment

### To build the AMI:
`packer build -var-file="packer-vars/<env>.json" cmx-runtime-environment-eks-worker.packer.json`
