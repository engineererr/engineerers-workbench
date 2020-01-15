function ProcessWeb{
    param($web)
    Connect-PnPOnline -Url $web.Url -Credentials $cred
    $lists = Get-PnPList

    foreach($l in $lists){
        if($l.BaseType -ne "DocumentLibrary" -or $l.Title -eq "Site Pages") { continue}

        $ctx = Get-PnPContext
        $checkedOutFiles = $null
        $ctx.Load($l)
        $ctx.ExecuteQuery()

        $checkedOutFiles = $l.GetCheckedOutFiles()
        $ctx.Load($checkedOutFiles)
        $ctx.ExecuteQuery()

        foreach($file in $checkedOutFiles){
            $filePath = "https://tomtominternational.sharepoint.com" + $file.ServerRelativePath.DecodedUrl
            "$filePath;$($web.Title);$($l.Title)" | Out-File -FilePath $outFilePath -Append
        }
        
        <#
        $camlQuery = "<View Scope='RecursiveAll'><Query><Where><IsNotNull><FieldRef Name='CheckOutStatus'/></IsNotNull></Where></Query></View>"
        $items = Get-PnPListItem -List $l
        foreach($file in $items){
            "https://tomtominternational.sharepoint.com$($file.ServerRelativePath.DecodedUrl);$($web.Title);$($l.Title)" | Out-File -FilePath $outFilePath -Append
        }
        #>
    }
}
$cred = Get-Credential
$site = "https://tomtominternational.sharepoint.com/teams/Telematics"

Connect-PnPOnline -Url $site -Credentials $cred
$outFilePath = ".\checkedOutFiles.csv"

$rootWeb = Get-PnPWeb
ProcessWeb $rootWeb
$subwebs = Get-PnPSubWebs -Recurse

foreach($web in $subwebs){
    ProcessWeb $web
}