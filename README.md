# Migrate on-premises SharePoint profile pictures to SharePoint Online
## Summary
In hybrid environments SharePoint users often have already uploaded their profile pictures to SharePoint on-premises user profile service.
 To ask them to upload the same images again, but this time to SharePoint Online, is a non viable solution for the users.


## Description
In hybrid environments SharePoint users often have already uploaded their profile pictures to SharePoint on-premises user profile service.
To ask them to upload the same images again, but this time to SharePoint Online, is a non viable solution for the users.
To prevent this, the script uploads the images from SharePoint on-premises to SharePoint Online.

The images are stored under "[MySiteHostUrl]/User Photos/".
After the upload, SharePoint generates three thumbnails in three different sizes called "logonname_SThumb.jpg", "logonname_MThumb.jpg" and "logonname_LThumb.jpg".

SharePoint Online doesn't provide an interface to upload profile pictures to the SharePoint user profile.
Therefore we are not able to generate the thumbnails on our own.
This is the reason for uploading the on-premises thumbnails instead of the original images to SharePoint Online.

If users upload their image manually, they have a couple of ways doing this:
a) In Delve, Profile Page, in Exchange Online and more.
Without an Exchange Online Mailbox: Delve saves the image to https://[tenant]-my.sharepoint.com in a library called "User Photos". SharePoint directly generates the thumbnails.
b) With an Exchange Online Mailbox: Delve saves the image to the Exchange Mailbox. SharePoints gets the images from Exchange Online and creates the thumbnails.

The script does the following:
iterates over all UPNs in the CSV file and does for each UPN the following
gets the user profile
checks if an image is already set
if not, uploads the thumbnails
updates UPS properties Picture URL to the URL of the Mthumb.jpg and SPS-PicturePlaceholderState to 0


## Tags
Sharepoint OnlineRemove
SharePoint 2013Remove
SharePoint 2016Remove
SharePoint 2019Remove
PowershellRemove
User Profile Service ApplicationsRemove
MigrationRemove

