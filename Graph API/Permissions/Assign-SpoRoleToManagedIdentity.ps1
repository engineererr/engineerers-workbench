$managedIdentityName = "MANAGED_IDENTITY_NAME"

$permissionsRequested = @(
    "User.ReadWrite.All"
)

$graphAppId = "00000003-0000-0ff1-ce00-000000000000" # Don't change this.

Connect-MgGraph -Scopes AppRoleAssignment.ReadWrite.All # You should be at least "Cloud Application Admin"

$managedIdentityServicePrincipal = Get-MgServicePrincipal -Filter "displayName eq '$managedIdentityName'"
$graphServicePrincipal = Get-MgServicePrincipal -Filter "appId eq '$graphAppId'"
$appRolesRequested = $graphServicePrincipal.AppRoles | Where-Object { ($_.Value -in $permissionsRequested) -and ($_.AllowedMemberTypes -contains "Application") }

foreach ($appRole in $appRolesRequested) {
    $appRoleAssignment = @{
        principalId = $managedIdentityServicePrincipal.Id
        resourceId  = $graphServicePrincipal.Id
        appRoleId   = $appRole.Id
    }
  
    # Works but not best practice
    # New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $managedIdentityServicePrincipal.Id -AppRoleId $appRole.Id -ResourceId $appRole.Id

    New-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $managedIdentityServicePrincipal.Id -BodyParameter $appRoleAssignment
    # Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $managedIdentityServicePrincipal.Id
    # Remove-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $managedIdentityServicePrincipal.Id -AppRoleAssignmentId
}
