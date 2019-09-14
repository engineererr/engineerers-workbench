<#
Modules to import:
AzureAD
WindowsAutoPilotIntune
MSGraphIntuneManagement
AzureRM.Profile
AzureRM.KeyVault
#>

Param  
(
    [Parameter (Mandatory = $false)]
    [string] $SerialNumber,

    [Parameter (Mandatory = $false)]
    [string] $HardwareHash,

    [Parameter (Mandatory = $false)]
    [string] $OrderIdentifier = "",

    [Parameter (Mandatory = $false)]
    [object]$WebhookData
)

if ($WebHookData) {

    # Collect properties of WebhookData
    $WebhookName = $WebHookData.WebhookName
    $WebhookHeaders = $WebHookData.RequestHeader
    $WebhookBody = $WebHookData.RequestBody

    $Input = (ConvertFrom-Json -InputObject $WebhookBody)

    $SerialNumber = $Input.SerialNumber
    $HardwareHash = $Input.HardwareHash
    $OrderIdentifier = $Input.OrderIdentifier
}

try {  
    Import-Module -Name WindowsAutoPilotIntune -ErrorAction Stop
}
catch {  
    throw 'Prerequisites not installed (WindowsAutoPilotIntune PowerShell module not installed'
}

# get client secret
$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection= Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

#Get the authentication token to access the Application
# Azure AD OAuth Application Token for Graph API
# Get OAuth token for a AAD Application (returned as $token)

# Application (client) ID, tenant ID and secret
$clientId = Get-AutomationVariable -Name IntuneGraphClientId
$tenantId = Get-AutomationVariable -Name TenantId
$clientSecret = (Get-AzureKeyVaultSecret -VaultName 'KeyVaultIntuneAutomation' -Name 'IntuneGraphClientSecret').SecretValueText
Write-Output $clientSecret
# Construct URI
$uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"

# Construct Body
$body = @{
    client_id     = $clientId
    scope         = "https://graph.microsoft.com/.default"
    client_secret = $clientSecret
    grant_type    = "client_credentials"
}

# Get OAuth 2.0 Token
$tokenRequest = Invoke-WebRequest -Method Post -Uri $uri -ContentType "application/x-www-form-urlencoded" -Body $body -UseBasicParsing

# Access Token
$Token = ($tokenRequest.Content | ConvertFrom-Json).access_token
Write-Output $Token

# The AutoPilotModule expects not only the authToken in the authToken variable but a IDictionary object to add it later as "header" to the Invoke-RestMethod cmdlet.
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", $Token)

# Set global variable authToken, to pass the Token to the WindowsAutoPilotIntune module
$global:authToken = $headers

#Register Device for AutoPilot
$dev = Add-AutoPilotImportedDevice -serialNumber $SerialNumber -hardwareIdentifier $HardwareHash -orderIdentifier $OrderIdentifier

$processingCount = 1
while ($processingCount -gt 0) {  
    $deviceStatuses = Get-AutoPilotImportedDevice -id $dev.id
    $deviceCount = $deviceStatuses.Length
    if (-not $deviceCount -and $deviceStatuses ) { $devicecount = 1}

    # Check to see if any devices are still processing
    $processingCount = 0
    foreach ($device in $deviceStatuses) {
        if ($device.state.deviceImportStatus -eq "unknown") {
            $processingCount = $processingCount + 1
        }
    }
    Write-Output "Waiting for $processingCount of $deviceCount"

    # Still processing?  Sleep before trying again.
    if ($processingCount -gt 0) {
        Start-Sleep 2
    }
}

# Display the statuses
$deviceStatuses | ForEach-Object {
    Write-Output "Serial number $($_.serialNumber): $($_.state.deviceImportStatus) $($_.state.deviceErrorCode) $($_.state.deviceErrorName)"
}

#Cleanup
Remove-AutoPilotImportedDevice -id $dev.id  