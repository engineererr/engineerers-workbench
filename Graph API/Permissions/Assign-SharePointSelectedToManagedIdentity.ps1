#TODO: Check if simpler with the following
Grant-PnPAzureADAppSitePermission -AppId bc7ead9c-ebc4-4927-9d31-e7ffd238c63e -DisplayName "SPO-Automation" -Permissions Write








# Source: https://learningbydoing.cloud/blog/connecting-to-sharepoint-online-using-managed-identity-with-granular-access-permissions/

# Add the correct 'Object (principal) ID' for the Managed Identity
$ObjectId = ""

# Add the correct 'Application (client) ID' and 'displayName' for the Managed Identity
$application = @{
    id = ""
    displayName = ""
}

$appRole = "read"
$spoTenant = "tenant.sharepoint.com"
$spoSite  = "siteName" # 


# Add the correct Graph scope to grant
$graphScope = "Sites.Selected"

Connect-MgGraph -Scope AppRoleAssignment.ReadWrite.All
$graph = Get-MgServicePrincipal -Filter "AppId eq '00000003-0000-0000-c000-000000000000'"
$graphAppRole = $graph.AppRoles | ? Value -eq $graphScope

$appRoleAssignment = @{
    "principalId" = $ObjectId
    "resourceId"  = $graph.Id
    "appRoleId"   = $graphAppRole.Id
}

New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $ObjectID -BodyParameter $appRoleAssignment | Format-List

$spoSiteId = $spoTenant + ":/sites/" + $spoSite + ":"

Import-Module Microsoft.Graph.Sites
Connect-MgGraph -Scope Sites.FullControl.All
New-MgSitePermission -SiteId $spoSiteId -Roles $appRole -GrantedToIdentities @{ Application = $application }