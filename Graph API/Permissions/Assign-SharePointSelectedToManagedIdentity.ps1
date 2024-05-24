# Source: https://learningbydoing.cloud/blog/connecting-to-sharepoint-online-using-managed-identity-with-granular-access-permissions/

# Add the correct 'Object (principal) ID' for the Managed Identity
$ObjectId = ""

# Add the correct 'Application (client) ID' and 'displayName' for the Managed Identity
$application = @{
    id = "827fc69f-2814-44d7-96bc-492f2bf21c83"
    displayName = "lbd-m365-automation-la"
}

$appRole = "read"
$spoTenant = ""
$spoSite  = ""


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

# No need to change anything below
$spoSiteId = $spoTenant + ":/sites/" + $spoSite + ":"

Import-Module Microsoft.Graph.Sites
Connect-MgGraph -Scope Sites.FullControl.All

New-MgSitePermission -SiteId $spoSiteId -Roles $appRole -GrantedToIdentities @{ Application = $application }