$items = gci C:\ExportFiles\UserPhotos\Profilbilder
$failedUsers = @()
"upn;newname" | Out-File -Append -FilePath output.csv

$items | % { 
    try {
        $fileName = $_.Name
        $underscoreIndex = $fileName.IndexOf("_")
        $thumbPart = $fileName.Substring($underscoreIndex)
        $upn = (Get-ADUser $fileName.Substring(0, $underscoreIndex) | select UserPrincipalName).UserPrincipalName
        $cleanedUpn = $upn.Replace(".", "_")
        $cleanedUpn = $cleanedUpn.Replace("@", "_")
        $newName = $cleanedUpn + $thumbpart
        Write-Host $newName
        "$upn;$newName" | Out-File -Append -FilePath output.csv
    }
    catch {
        $failedUsers += $filename
    }
}

Write-Host $failedUsers
