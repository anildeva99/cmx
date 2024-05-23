write-output "Setting up Dundas"
write-host "(host) setting up Dundas"

$dir = "C:\Program Files (x86)\Dundas Data Visualization Inc\Dundas BI\Setup"

# Create Dundas Cert
$Cert = New-SelfSignedCertificate -CertstoreLocation Cert:\LocalMachine\My -DnsName "dundasbi-certificate"

# Get AWS Config
$region = $(Invoke-RestMethod -Method GET -Uri http://169.254.169.254/latest/meta-data/placement/availability-zone)
$region = $region.subString(0, $region.length - 1)

$instance = $(Invoke-RestMethod -Method GET -Uri http://169.254.169.254/latest/meta-data/instance-id)

# Retreve Dundas Config Secret Name from Instance Tag
$config_secret = $(Get-EC2Tag -Filter @{ Name = "resource-id"; Value = $instance }, @{Name="tag:ConfigSecret"; Value = "*"}).Value
# Retreive Environment Name from Instance Tag
$environment = $(Get-EC2Tag -Filter @{ Name = "resource-id"; Value = $instance }, @{Name="tag:Environment"; Value = "*"}).Value
# Get Config Secret Value
$response = $(Get-SECSecretValue -Region $region -SecretId $config_secret).SecretString -replace "'", '"'
$config = $response | ConvertFrom-JSON

# Get License From AWS S3 Bucket
$license=$(Read-S3Object -BucketName configuration.$environment.datacentral.codametrix.com -Key dundas_license.xml -File $dir/dundas_license.xml)

# Get Dundas Vars
$license_clear = cat $dir/dundas_license.xml
$env:LICENSE= $license_clear -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;' -replace '"', "&quot;" -replace "'", "&#39;"
$env:ADMIN_USER=$config.ADMIN_USER
$env:ADMIN_EMAIL=$config.ADMIN_EMAIL
$env:DB_USER=$config.DB_USER
$env:DB_WAREHOUSE_USER=$config.DB_WAREHOUSE_USER
$env:DB_ADDRESS=$config.DB_ADDRESS
$env:DB_WAREHOUSE_ADDRESS=$config.DB_WAREHOUSE_ADDRESS
$env:SMTP_SERVER=$config.SMTP_SERVER
$env:SMTP_USER=$config.SMTP_USER
$env:DB_PORT=$config.DB_PORT
$env:DB_WAREHOUSE_PORT=$config.DB_WAREHOUSE_PORT

# Retrieve/Generate Other Values
$env:ADMIN_PASS=$config.ADMIN_PASS
$env:DB_PASS=$config.DB_PASS
$env:DB_WAREHOUSE_PASS=$config.DB_WAREHOUSE_PASS
$env:WAREHOUSE_DB=$config.WAREHOUSE_DB
$env:APPLICATION_DB=$config.APPLICATION_DB

# Establish SSL Tunnel Configuration
$env:DB_TUNNEL_URL='localhost'
$env:DB_TUNNEL_PORT=5432
$env:DB_WAREHOUSE_TUNNEL_URL='localhost'
$env:DB_WAREHOUSE_TUNNEL_PORT=5433
$stunnel_dir = 'C:\Program Files (x86)\stunnel\'
$template = cat C:\Windows\Temp\stunnel_config.txt
$expanded_raw = $ExecutionContext.InvokeCommand.ExpandString($template)
$expanded_clean_newline = $expanded_raw -replace ' ', '`r`n'
$ExecutionContext.InvokeCommand.ExpandString($expanded_clean_newline) | Out-File "$stunnel_dir\config\stunnel.conf" -Encoding UTF8

# Run Stunnel to Establish SSL Tunnels
& $stunnel_dir\bin\stunnel.exe $stunnel_dir\config\stunnel.conf

# Populate Dundas Deployment Template
$template = cat C:\Windows\Temp\dundas_deployment.xml
$expanded = $ExecutionContext.InvokeCommand.ExpandString($template)
Set-Content -Path "$dir\dundas-instance-deployment.xml" -Value $expanded

# Run Dundas Installation
$version = (Get-ChildItem -Directory -Path $dir).Name
& $dir\$version\DeploymentConsole.exe /action $dir\dundas-instance-deployment.xml
