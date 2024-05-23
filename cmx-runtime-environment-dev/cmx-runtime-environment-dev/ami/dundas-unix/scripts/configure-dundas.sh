#!/bin/bash -x
set -e
set -x

#Updates
apt-get -y update
apt-get -y upgrade


wget https://packages.microsoft.com/config/ubuntu/19.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
apt-get install apt-transport-https
apt-get update

#Custom Tools
apt-get install -y python-pip \
          jq \
          liblttng-ust0 \
          dotnet-sdk-3.1 \
          dotnet-runtime-3.1 \
          python3-pip \
          libnss3 \
          libgdiplus \
          libsdl2-image-2.0-0

pip install awscli

# Get AWS Values
region=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone)
region=${region::-1}

# Configure AWS CLI
mkdir /root/.aws/
touch /root/.aws/config
printf "[default]\noutput = json\nregion = $region\ncredential_source = Ec2InstanceMetadata" >> /root/.aws/config

instance=$(curl http://169.254.169.254/latest/meta-data/instance-id)

# Retreve Dundas Config Secret Name from Instance Tag
config_secret=$(aws --debug ec2 describe-tags --filters "Name=resource-id,Values=$instance" "Name=tag:ConfigSecret,Values=*" | jq .Tags[0].Value)
# Retreive Environment Name from Instance Tag
environment=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$instance" "Name=tag:Environment,Values=*" | jq .Tags[0].Value)
# Get Config Secret Value
response=$(aws secretsmanager get-secret-value --secret-id ${config_secret:1:-1} | jq .SecretString)
# Parse breakouts and remove leading/trailing quotes
config=$(echo ${response:1:-1} | tr "'" '"')
# Get License From AWS S3 Bucket
license=$(aws s3 cp s3://configuration.${environment:1:-1}.datacentral.codametrix.com/dundas_license.xml /home/ubuntu/dundas_license.xml)

# Default Values for Template
export LICENSE=$(cat /home/ubuntu/dundas_license.xml | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g')
export ADMIN_USER=$(echo $config | jq -r .ADMIN_USER)
export ADMIN_EMAIL=$(echo $config | jq -r .ADMIN_EMAIL)
export DB_USER=$(echo $config | jq -r .DB_USER)
export DB_WAREHOUSE_USER=$(echo $config | jq -r .DB_WAREHOUSE_USER)
export APPLICATION_DB=$(echo $config | jq -r .APPLICATION_DB)
export WAREHOUSE_DB=$(echo $config | jq -r .WAREHOUSE_DB)
export DB_ADDRESS=$(echo $config | jq -r .DB_ADDRESS)
export DB_WAREHOUSE_ADDRESS=$(echo $config | jq -r .DB_WAREHOUSE_ADDRESS)
export SMTP_SERVER=$(echo $config | jq -r .SMTP_SERVER)
export SMTP_USER=$(echo $config | jq -r .SMTP_USER)
export DB_PORT=$(echo $config | jq -r .DB_PORT)
export DB_WAREHOUSE_PORT=$(echo $config | jq -r .DB_WAREHOUSE_PORT)

# Retreive/Generate Other Values\
export ADMIN_PASS=$(echo $config | jq -r .ADMIN_PASS)
export DB_PASS=$(echo $config | jq -r .DB_PASS)
export DB_WAREHOUSE_PASS=$(echo $config | jq -r .DB_WAREHOUSE_PASS)


#// Modify this variable to include your AWS Secret Access Key
key=$(echo $config | jq -r .SMTP_PASS)
#// Modify this variable to refer to the AWS Region that you want to use to send email.
#// The values of the following variables should always stay the same.
date="11111111"
service="ses"
terminal="aws4_request"
message="SendRawEmail"
versionInBytes="0x04"

kDate=$(echo "$date" | openssl sha1 -hmac "AWS4$key")
kRegion=$(echo "$region" | openssl sha1 -hmac "$kDate")
kService=$(echo "$service" | openssl sha1 -hmac "$kRegion")
kTerminal=$(echo "$terminal" | openssl sha1 -hmac "$kService")
kMessage=$(echo "$message" | openssl sha1 -hmac "$kTerminal")
signatureAndVersion="$versionInBytes$kMessage"
export SMTP_PASS=$(echo $signatureAndVersion | base64 )

# Populate Template w/ Values
envsubst < /home/ubuntu/dundas-deployment.xml > /home/ubuntu/deployment.xml

# Default Values for Template
unset LICENSE \
      ADMIN_USER \
      ADMIN_EMAIL \
      DB_USER \
      DB_WAREHOUSE_USER \
      DB_ADDRESS \
      DB_WAREHOUSE_ADDRESS \
      SMTP_SERVER \
      SMTP_USER \
      DB_PORT \
      DB_WAREHOUSE_PORT \
      SMTP_PASS \
      ADMIN_PASS \
      DB_PASS \
      DB_WAREHOUSE_PASS

#Unpackage Dundas Deployment Tool
dpkg -i /home/ubuntu/dundas-installer.deb

# Run Deployment
dundasbi --action /home/ubuntu/deployment.xml
