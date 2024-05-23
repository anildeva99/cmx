# Codametrix Runtime environment Dundas AMI
This project builds an AMI to be used in the application runtime environment

### To build the Dundas AMI (first time):
1. Create a secret in AWS Secrets Manager named `CodaMetrixDataCentral/Dundas/WindowsRemoteUser`
  1. Add a Key of `User` with the username `Dundas`
  2. Add a Key of `Password` with a strong password
2. Run `packer build -var-file="packer-vars/<env>.json" cmx-runtime-environment-dundas.packer.json`
3. Manually launch a new instance from the AMI created in Step 2 and log into it:
  1. Navigate to the AWS EC2 Console
  2. Select the instance you created and go to "Actions" > "Launch"
  3. On the "Configure Instance" page, select the IAM role containing `_dundas_instance_role` in the name
  4. On the "Configure Security Group" page, create a new security group and restrict it to only your IP Address
  5. Select the `codametrixdatacentral-<<ENV>>-dundas` keypair & launch the image
  6. Log in using the credentials created in step 1
4. Open PowerShell (x86) as an Administrator, run `& C:\Users\Administrator\Downloads\Dundas.BI.Setup.exe` and install Dundas files (use default settings)
5. Launch the deployment application and select "Deployments" > "Create an Instance" and install dependencies by clicking "Fix All" (do NOT deploy an instance)
6. Ensure that the Dundas user is set so that their password doesn't expire and doesn't change on next login.
7. Create a snapshot of the AMI for use in the AWS Console, named `cmx-runtime-environment-dundas-1.0a`.
8. Log out and terminate the instance
9. Complete steps found under "To configure the Dundas DBs (new region)" (use the new snapshot ID as the Dundas AMI, skip Step 2 using the existing instance for Step 3)

NOTE: Dundas BI Installer sometimes will be hidden and you will get an error that the process is already running.
To fix this, run `Stop-Process -Name Dundas.BI.Setup` and re-launch the installer.

### To deploy Dundas (new account):
1. Log in to an AWS account which currently has a Dundas instance running
2. Copy the Dundas AMI & `CodaMetrixDataCentral/Dundas/WindowsRemoteUser` secret to the new account
3. Complete steps found under "To configure the Dundas DBs (new region)"

### To configure the Dundas DBs (new region):
1. Run the `provision-environment.yml` and `prepare-database.yml` playbooks, using the Dundas snapshot AMI for `dundas_amis`
2. Log into the Dundas instance using the credentials found in the `CodaMetrixDataCentral/Dundas/WindowsRemoteUser` secret. You will need to open an SSH tunnel to the IP address of the instance on port 3389 for this.
3. Execute `& C:\Windows\Temp\configure-dundas.ps1` in PowerShell (x86) as an Administrator to establish the SSL Tunnels to the DBs
4. [Only Required if Above Script Fails] Launch the Dundas Deployment Application and deploy a Dundas instance to configure the required DBs. Use default settings besides:
  1. On the application database option screen, select "Create a New Database". Use the following connection settings:
    1. Host: `localhost`
    2. User: value of `dundas_application_database_username` in `ansible\data-central-environment\roles\environment-common\vars\<<ENV>>.yml`
    3. Password: found in AWS Secret `CodaMetrixDataCentral/Dundas/ApplicationDatabase/<ENV>-<USER>`
    4. Database: value of `dundas_application_database_name` in `ansible\data-central-environment\roles\environment-common\defaults\main.yml`
  2. On the warehouse database option screen, uncheck "Use Application Database Connection". Use the following connection settings:
    1. Host: `localhost,5433`
    2. User: value of `dundas_warehouse_database_username` in `ansible\data-central-environment\roles\environment-common\<<ENV>>.yml`
    3. Password: found in AWS Secret `CodaMetrixDataCentral/Dundas/WarehouseDatabase/<ENV>-<USER>`
    4. Database: value of `dundas_warehouse_database_name` in `ansible\data-central-environment\roles\environment-common\defaults\main.yml`
  3. Log out and terminate the Dundas instance, wait for a new instance to spawn.
  4. Log into the new instance and execute `& C:\Windows\Temp\configure-dundas.ps1` in PowerShell (x86) as an Administrator

### Final steps:
1. Dundas will be installed as a "Virtual Directory" underneath the Default website in IIS. You will need to set the bindings on that Default website to enable HTTPS, using the dundas-certificate cert which is installed by the steps above.
2. To configure stunnel as a Windows service, go to Start > "stunnel AllUsers" > "stunnel Service Install". Then go to the Windows services manager, find "Stunnel TLS wrapper" and tell it to start.
3. Emails will usually come from dundasbi@codametrix.com or a similar email address. For that to happen, the codametrix.com domain has to be added and verified in AWS SES. This currently isn't being done in code, as Dundas isn't typically run in the same account as the codametrix.com Route53 hosted zone, and verifying an SES domain involves adding a record to the hosted zone. So this step must be done manually for emails from Dundas to work.
4. Set the Recovery properties on the "Dundas BI" and "Stunnel TLS wrapper" Windows services so that they restart on failure.
5. Configure the Dundas application pool in IIS to recycle every night at midnight. 

WINRM Upload Speeds are impacted by: https://github.com/packer-community/winrmcp/pull/6
