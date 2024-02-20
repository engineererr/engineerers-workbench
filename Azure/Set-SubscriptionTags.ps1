#Connect-AzAccount
$setNewTags = $true # Set to true to set new tags, false will report existing tags

$rows = Import-Csv ".\Azure\subscriptions.csv"
foreach ($row in $rows) {
    $subId = $row.id
    $sub = Get-AzSubscription -SubscriptionId $subId
    if ($null -eq $sub) {
        Write-Host "Subscription not found: $($row.name)"
        continue
    }

    if ($setNewTags) {
        Write-Host "Setting Tags for $($sub.Name):" -ForegroundColor Green

        $mergeTags = @{
            "Service"           = $row.Service;
            "BusinessOwner"     = $row.BusinessOwner;
            "ServiceOrAppOwner" = $row.ServiceOrAppOwner;
        }

        # Merge adds new tags and updates existing ones, but doesn't remove tags. Replace would remove tags not in the new list.
        Update-AzTag -Tag $mergeTags -ResourceId "subscriptions/$subId" -Operation Merge
    }else{
        Write-Host "Reporting Tags for $($sub.Name):" -ForegroundColor Green
        Get-AzTag -ResourceId "subscriptions/$subId"
    }
}