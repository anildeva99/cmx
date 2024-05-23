How To Create Proxy For Kibana Log In
=======================================

 *example: ./bastion_proxy.sh -p <profile name>
 *choose all default values

 *Take note of the port number for your tunneling.
 
 *Configure the SOCKS proxy
  1.     Add FoxyProxy Standard to Google Chrome.
  2.    Open FoxyProxy, and then choose Options.
  3.    In the Proxy mode drop-down list, choose Use proxies based on their pre-defined patterns and priorities.
  4.    Choose Add New Proxy.
  5.    Select the General tab and enter a Proxy Name, such as "Kibana Proxy."
  6.    On the Proxy Details tab, be sure that Manual Proxy Configuration is selected and then complete the following fields:
        For Host or IP Address, enter localhost.
        For Port, enter THE PORT NUMBER ASSIGNED TO YOUR BY TUNNELING.
        Select SOCKS proxy
        Select SOCKS v5.
  7.    Choose the URL Patterns tab.
  8.    Choose Add new pattern and then complete the following fields:
         For Pattern Name, enter a name that makes sense to you, such as "VPC Endpoint."
         For URL pattern, enter the VPC endpoint for Kibana. Be sure that Whitelist URLs is selected. Be sure that Wildcards is selected.
         VPC endpoint for Kibana  can be found on AWS Cognito User Pool --> Applicaton client setting
  9.     Choose Save.


