# Codametrix Runtime environment Dundas AMI
## This project builds an AMI to be used in the application runtime environment

NOTE: THIS IS STILL WIP. CAN NOT BE COMPLETED UNTIL UNIX DUNDAS SUPPORTS SSO.

### To build the Ubuntu AMI:
1. Download the Dundas BI Ubuntu installer from [your account](https://www.dundas.com/support/my-account/#downloads), then rename it to `dundas-installer.deb` before placing it in the `files/` directory.
2. Run `packer build -var-file="packer-vars/<env>-sh.json" cmx-runtime-environment-dundas.packer-sh.json`
