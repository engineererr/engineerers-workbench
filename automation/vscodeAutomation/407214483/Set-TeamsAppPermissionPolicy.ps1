Import-Module MicrosoftTeams

# https://learn.microsoft.com/en-us/powershell/module/skype/grant-csteamsapppermissionpolicy?view=skype-ps
# Grant-CsTeamsAppPermissionPolicy -Identity "Roger von Rohr" -PolicyName "id-policy"
# Michael probably migrated already to Teams PowerShell or Graph SDK PowerShell
# we wait for his script

# https://learn.microsoft.com/en-us/powershell/module/teams/connect-microsoftteams?view=teams-ps
# https://learn.microsoft.com/en-us/MicrosoftTeams/teams-powershell-application-authentication#setup-application-based-authentication
# $appId = $env:appId
# $appSecret = $env:secret

Connect-MicrosoftTeams -Identity
Connect-MgGraph -Identity

$mapping = @{
    "id_teams_policy_group" = "id_policy"
}

$group = Get-MgGroup -Filter "DisplayName eq 'Test Security Group'"
$members = Get-MgGroupMember -GroupId $group.Id

# foreach($row in $mapping.Keys){
#     $members = Get-MgGroupMembers $mapping
#     # https://learn.microsoft.com/en-us/powershell/module/teams/new-csbatchpolicyassignmentoperation?view=teams-ps
#     New-CsBatchPolicyAssignmentOperation -PolicyType TeamsAppPermissionPolicy -PolicyName $mapping[$row] -Identity $members -OperationName "$row Batch"
# }