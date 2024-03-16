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
    "id_policy" = "id_teams_policy_group"
    "institutA_policy" = "A_teams_policy_group"
}

foreach($row in $mapping){
    $members = Get-MgGroupMembers $groupName
    # https://learn.microsoft.com/en-us/powershell/module/teams/new-csbatchpolicyassignmentoperation?view=teams-ps
    New-CsBatchPolicyAssignmentOperation -PolicyType TeamsAppPermissionPolicy -PolicyName "unibe - id - app policy" -Identity $members -OperationName "ID App Policy Batch"
}