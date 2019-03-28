<# 
.SYNOPSIS 
    The script uploads the SharePoint on-premises generated profile picture thumbnails to SharePoint Online. 
    This way, users won't have to upload their profile picture again.

.DESCRIPTION 
    In hybrid environments SharePoint users often have already uploaded their profile pictures to SharePoint on-premises user profile service.
    To ask them to upload the same images again, but this time to SharePoint Online, is a non viable solution for the users. 
    To prevent this, the script uploads the images from SharePoint on-premises to SharePoint Online.

    The images are stored under "[MySiteHostUrl]/User Photos/". 
    After the upload, SharePoint generates three thumbnails in three different sizes called "logonname_SThumb.jpg", "logonname_MThumb.jpg" and "logonname_LThumb.jpg".

    SharePoint Online doesn't provide an interface to upload profile pictures to the SharePoint user profile.
    Therefore we are not able to generate the thumbnails on our own.
    This is the reason for uploading the on-premises thumbnails instead of the original images to SharePoint Online.

    If users upload their image manually, they have a couple of ways doing this: In Delve, Profile Page, in Exchange Online and more.
    a) Without an Exchange Online Mailbox: Delve saves the image to https://[tenant]-my.sharepoint.com in a library called "User Photos". SharePoint directly generates the thumbnails.
    b) With an Exchange Online Mailbox: Delve saves the image to the Exchange Mailbox. SharePoints gets the images from Exchange Online and creates the thumbnails.

    The script does the following:
    - iterates over all UPNs in the CSV file and does for each UPN the following
    -- gets the user profile
    -- checks if an image is already set
    -- if not, uploads the thumbnails
    -- updates UPS properties Picture URL to the URL of the Mthumb.jpg and SPS-PicturePlaceholderState to 0

.Example
    Change the variables in variables section.
    Run the script.

.NOTES 
    Version:        1.0
    Author:         Kai Boschung from https://engineerer.ch
    Creation Date:  18.03.2019

.COMPONENT 
PnP PowerShell is needed: https://docs.microsoft.com/en-us/powershell/sharepoint/sharepoint-online/connect-sharepoint-online?view=sharepoint-ps

.LINK
How to install PnP PowerShell: https://docs.microsoft.com/en-us/powershell/sharepoint/sharepoint-online/connect-sharepoint-online?view=sharepoint-ps

.Parameter imagesFolderPath 
represents the path to the already downloaded on-premises images. You can download the images with Explorer View or this script: https://gallery.technet.microsoft.com/office/Bulk-Export-SharePoint-51857b22

.Parameter csvPath
represents the path to a CSV in the following format:

upn;imageName
kai.boschung@engineerer.ch;Kai_Boschung_engineerer_ch_LThumb.jpg

This CSV was generated on-premises by using this script: XXXXXXXXXXXXXX
#>

#region functions
function Upload-Images($fileNames, $folder = "User Photos/Profilbilder") {
    foreach ($file in $fileNames) {
        Add-PnPFile -Path $file.imageName -Folder $folder -Connection $oneDriveConnection
    }
}
#endregion

#region variables
$imagesFolderPath = "C:\projects\pictureMigration\on-premises-images"
$csvPath = "C:\projects\pictureMigration\pictures.csv"
$tenantName = "engineerer"
#endregion

#region setup
cd $imagesFolderPath
# used to upload images
# I use web login because my account has MFA enabled
# tested as an onmicrosoft.com account with SharePoint Admin permissions
$oneDriveConnection = Connect-PnPOnline -Url "https://$tenantName-my.sharepoint.com" -UseWebLogin -ReturnConnection
# used to update UPS properties
Connect-PnPOnline -Url "https://$tenantName-admin.sharepoint.com" -UseWebLogin
#endregion

$changedUsers = @()
$picturesCsv = Import-Csv -Delimiter ";" -LiteralPath $csvPath

# group the three thumbnails for each UPN
$groupedPictureCsv = $picturesCsv | Group-Object -Property "upn"

$groupedPictureCsv | % {
    try {
        $upn = $_.Name
        $fileNames = $_.Group | select imageName
        # the link to MThumb is set in UPS
        $pictureName = ($_.Group | ? imageName -like "*MThumb.jpg").imageName
        $profile = Get-PnPUserProfileProperty -Account $upn
        # determines if the user still has a placeholder image set
        $placeholderState = $profile.UserProfileProperties."SPS-PicturePlaceholderState"
        $pictureUrl = $profile.PictureUrl
        Write-Host "PictureUrl: $pictureUrl"
        Write-Host "UserProfileProperties.SPS-PicturePlaceholderState: $placeholderState"

        if ($placeholderState -eq 1 -or $placeholderState -eq "") {
            if ($pictureUrl -ne $null) {
                Write-Host "Skipping because picture url for $upn is not null: $pictureUrl"
                continue
            }

            # upload image
            Upload-Images -fileNames $fileNames 

            # update profile
            Set-PnPUserProfileProperty -Account $upn -PropertyName "PictureUrl" -Value "https://$tenantName-my.sharepoint.com:443/User%20Photos/Profilbilder/$pictureName"
            Set-PnPUserProfileProperty -Account $upn -PropertyName "SPS-PicturePlaceholderState" -Value 0

            $changedUsers += $upn
        }
    }
    catch {
        Write-Host "ERROR for user $upn"
    }

}