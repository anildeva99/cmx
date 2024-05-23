# Download Dundas
$url = "https://www.dundas.com/support/files/dbi/DBI_INST/7.0/7.0.2.1003/Dundas.BI.Setup.7.0.2.1003.exe"
$output = "C:\Users\Administrator\Downloads\Dundas.BI.Setup.exe"
Invoke-WebRequest -Uri $url -OutFile $output

# Install Tools
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install stunnel -y

# Configure AWS
C:\ProgramData\Amazon\EC2-Windows\Launch\Scripts\InitializeInstance.ps1 -Schedule
