Connect-PnPMicrosoftGraph -Scopes "Group.Read.All", "Directory.Read.All"

$results = @()

Get-PnPUnifiedGroup | % { 
    $owner = Get-PnPUnifiedGroupOwners -Identity $_.groupid
    Write-Host "$($owner.DisplayName), $($_.SiteUrl)"
    if($owner.Count -gt 1){
        $results += [pscustomobject]@{Url=$_.SiteUrl;Owner="$(owner[0].DisplayName),$($owner[0].DisplayName)";OwnerUpn="$($owner[0].UserPrincipalName),$($owner[1].UserPrincipalName)"}
    }else{
        $results += [pscustomobject]@{Url=$_.SiteUrl;Owner=$owner.DisplayName;OwnerUpn=$owner.UserPrincipalName}
    }
}

$results | Export-Csv -Path C:\temp\groupsExport.csv -NoTypeInformation -Delimiter ";"