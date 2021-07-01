<#
Source: https://docs.microsoft.com/en-us/graph/api/user-get?view=graph-rest-beta&tabs=http
#>
Install-Module -Name MSAL.PS -RequiredVersion 4.2.1.3
Import-Module MSAL.PS
$tenantID = ""
$appId = ""
$appSecret = ""

$ConfidentialClientOptions = New-Object Microsoft.Identity.Client.ConfidentialClientApplicationOptions -Property @{ ClientId = $appId; TenantId = $tenantID; ClientSecret = $appSecret }
$ConfidentialClient = $ConfidentialClientOptions | New-MsalClientApplication
$tokenObj = Get-MsalToken -Scope 'https://graph.microsoft.com/.default' -ConfidentialClientApplication $ConfidentialClient
$apiUrl = "https://graph.microsoft.com/beta/users?filter=signInActivity/lastSignInDateTime le 2021-06-21T00:00:00Z&`$select=userPrincipalName,displayName,mail,signInActivity"
$res = Invoke-RestMethod -Headers @{Authorization = "Bearer $($tokenObj.AccessToken)"} -Uri $apiUrl -Method Get

$res.value | select userPrincipalName, displayName, mail, @{L="LastSignInDateTime";E={$_.signInActivity.lastSignInDateTime}} | Sort-Object -Property LastSignInDateTime