# not yet finished
# used to setup required resources in azure

Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'

az login
az ad app create --display-name IntunesGraph2 --native-app --required-resource-accesses 'C:\projects\auto-pilot-registration\IntunesGraphManifest.json' --reply-urls 'urn:ietf:wg:oauth:2.0:oob'
az ad app permission admin-consent --id [--subscription]