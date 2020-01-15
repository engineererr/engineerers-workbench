# credit: https://blog.kloud.com.au/2018/04/26/how-to-make-property-bag-values-indexed-and-searchable-in-sharepoint-online/

$cred = Get-Credential
$tenantName = "cellere"
$siteUrl = "https://cellere.sharepoint.com/sites/bauaktepoc"
$properties = @(
    @{"name" = "OffertNr";"value" = 123},
    @{"name" = "PSP";"value" = 456}
)
Connect-SPOService  "https://$tenantName-admin.sharepoint.com" -Credential $cred
Connect-PnPOnline  $siteUrl -Credentials $cred
Set-SPOSite $siteUrl -DenyAddAndCustomizePages 0
foreach($prop in $properties){
    Set-PnPPropertyBagValue -Key $prop.name -Value $prop.value -Indexed
}
Set-SPOSite $siteUrl -DenyAddAndCustomizePages 1