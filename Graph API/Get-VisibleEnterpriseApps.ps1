Connect-MgGraph

$visibleApps = Get-MgServicePrincipal | ? tags -NotContains "HideApp" 

$results = @()
foreach ($app in $visibleApps) {
    $appRoles = Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $app.id
    if ($appRoles.count -gt 0) {
        $adminOnly = $true
        foreach ($role in $appRoles) {
            if ($role.PrincipalDisplayName -notlike "*admin*") {
                $adminOnly = $false
                break
            }
        }

        if (-not $adminOnly) {
            $results += [PSCustomObject]@{
                AppName  = $app.displayName
                AppRoles = $appRoles
            }
        }
    }
}