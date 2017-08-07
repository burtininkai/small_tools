## Version 0.2
## 2017-08-04 13:13

$search_string = 'FLMS031361'
$replace_string = 'AbsoluteIrradiance'

if ($(Read-host -Prompt "Check SubDirectories? (YES or NO)") -like "Y*") {
    $params = @{
        'path' = $PSScriptRoot;
        'recurse' = $true;
        'filter' = "*$search_string*";
    }
}
else {
    $params = @{
        'path' = $PSScriptRoot;
        'recurse' = $false;
        'filter' = "*$search_string*";
    }
}
$count = 0

dir @params | foreach {$item = $_; $new_name = $_.Name.replace($search_string,$replace_string); Rename-Item -Path $item.FullName -NewName $new_name; ++$count}

clear
Write-Host "All Done. Renamed $count files" -ForegroundColor Red
sleep 10