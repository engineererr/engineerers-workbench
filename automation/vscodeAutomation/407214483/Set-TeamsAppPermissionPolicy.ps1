# https://learn.microsoft.com/en-us/powershell/module/teams/connect-microsoftteams?view=teams-ps
# https://learn.microsoft.com/en-us/MicrosoftTeams/teams-powershell-application-authentication#setup-application-based-authentication

# Setup: Grant Group.Read.All and Teams Admin to managed identity

Connect-MicrosoftTeams -Identity
Connect-MgGraph -Identity -NoWelcome

$mapping = @{
    "Test Security Group" = "id_policy"
}

Write-Output "Existing App Permission Policies"
Get-CsTeamsAppPermissionPolicy

foreach ($row in $mapping.Keys) {
    $group = Get-MgGroup -Filter "DisplayName eq '$row'"
    if($group.Count -ne 1) {
        Write-Output "Group not found or not unique: $row"
        continue
    }
    $members = Get-MgGroupMember -GroupId $group.Id
    Write-Output $members
    # https://learn.microsoft.com/en-us/powershell/module/teams/new-csbatchpolicyassignmentoperation?view=teams-ps
    New-CsBatchPolicyAssignmentOperation -PolicyType TeamsAppPermissionPolicy -PolicyName $mapping[$row] -Identity $members.Id -OperationName "$row Batch"
}