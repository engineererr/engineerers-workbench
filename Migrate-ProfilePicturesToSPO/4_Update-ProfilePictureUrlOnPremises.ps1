[void][reflection.assembly]::Loadwithpartialname("Microsoft.Office.Server"); 
Add-PSSnapin Microsoft.SharePoint.PowerShell

$onPremisesUrl = "https://collaboration.engineerer.ch"
$tenantName = "engineerer"

$site = Get-SPSite $onPremisesUrl
$serviceContext = Get-SPServiceContext $site;

$upm = new-object Microsoft.Office.Server.UserProfiles.UserProfileManager($serviceContext);
$userProfile = $upm.GetUserProfile("kai.boschung@engineerer.ch");

$userProfile["PictureUrl"].Value = "https://$tenantName-my.sharepoint.com:443/User%20Photos/Profilbilder/kai_boschung_engineerer_ch_MThumb.jpg";   
$userProfile.Commit()
