Get-MsolUser "kboschun-t@snf-t.ch"  | Set-MsolUser -UsageLocation CH
Set-MsolUserLicense -AddLicenses "snsft:STANDARDWOFFPACK_FACULTY"