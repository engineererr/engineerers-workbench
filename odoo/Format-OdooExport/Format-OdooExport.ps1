$csvFiles = Get-ChildItem -Path ./input -Filter *.csv

foreach ($csvFile in $csvFiles) {
    $content = Get-Content $csvFile.FullName
    $header = $content | Select-Object -Skip 11 -First 1
    $lines = $content | Select-Object -Skip 12
    try{
        $sorted = $lines | Sort-Object { [DateTime]::ParseExact($_.Split(';')[0], 'dd.MM.yyyy', $null) } -ErrorAction Stop

    }catch{
        $sorted = $lines | Sort-Object { [DateTime]::ParseExact($_.Split(';')[0], 'dd.MM.yy', $null) }
    }
    $fullFile = @($header) + $sorted
    $fullFile | Set-Content -Path "./output/$($csvFile.Name)_cleaned.csv"
}