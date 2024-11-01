#Original from: https://www.sharepointdiary.com/2019/08/sharepoint-online-web-part-usage-report-using-powershell.html#ixzz8eQAs8Lio

$CSVPath = "C:\Temp\webparts.csv"
$tenant = "mytenant"
$ownerToSetTemporarely = "admin@$tenant.onmicrosoft.com"

$spoUrl = "https://$tenant.sharepoint.com"
$adminUrl = "https://$tenant-admin.sharepoint.com"
#TODO: Get Valo Sites
$tenantConnection = Connect-PnPOnline -Url $adminUrl -Interactive -ReturnConnection
$sites = Get-PnPTenantSite -Connection $tenantConnection

foreach ($s in $sites) {
    $siteUrl = $s.Url

    Write-Host "Working on $siteUrl" -ForegroundColor Green
    
    try {
        Set-PnPTenantSite -Identity $siteUrl -Owners $ownerToSetTemporarely -Connection $tenantConnection
        Connect-PnPOnline -Url $siteURL -Interactive

        #Get all pages from "Site Pages" library
        $SitePages = $null
        try {
            $SitePages = Get-PnPListItem -List "Site Pages"
        }
        catch {
            $SitePages = Get-PnPListItem -List "Websiteseiten"
        }

        $WebPartsData = @()
        #Iterate through each page
        ForEach ($Page in $SitePages) {
            $pageFileLeafRef = $Page.FieldValues.FileLeafRef
            #Get All Web parts from the page
            try {
                $clientSidePage = Get-PnPClientSidePage -Identity $pageFileLeafRef
                $webparts = $clientSidePage.Controls
            }
            catch {
                Write-Host "Error getting webparts for page $pageFileLeafRef" -ForegroundColor Red
                continue
            }
            #Iterate through webparts and collect details
            ForEach ($webpart in $webparts) { 
                #Get Web part properties
                $WebPartsData += New-Object PSObject -Property @{
                    "SiteUrl"            = $siteUrl
                    "PageUrl"            = $Page.FieldValues.FileRef
                    "PageAbsoluteUrl"    = $spoUrl + $Page.FieldValues.FileRef
                    "PageTitle"          = $Page.FieldValues.Title
                    "WebPart Title"      = $webpart.Title
                    "WebPart Properties" = $Webpart.PropertiesJson
                }      
            }
        }
        #Export Web part data to CSV
        if ($WebPartsData.Count -gt 0) {
            $WebPartsData
            $WebPartsData | Export-Csv -Path $CSVPath -NoTypeInformation -Append
        }
    }
    catch {
        Write-Host "Error for site '$siteUrl'" -ForegroundColor Red
        $_
    }
    finally {
        Remove-PnPSiteCollectionAdmin -Owners $ownerToSetTemporarely
    }
}

