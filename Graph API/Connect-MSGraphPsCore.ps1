# https://developer.microsoft.com/en-us/office/blogs/microsoft-graph-advanced-queries-for-directory-objects-are-now-generally-available/

# PowerShell Core required
Install-Module Microsoft.Graph -Repository PSGallery
Get-Command -Module Microsoft.Graph*

$certificateThumbprint = ""
$clientId = ""
$tenantId = ""
$cert = Get-ChildItem Cert:\LocalMachine\My\$certificateThumbprint
Connect-Graph -Certificate $cert -ClientId $clientId -TenantId $tenantId

# advanced query capabilitites
Get-MgUser -consistencyLevel eventual -count userCount -search '"displayName:room"' 