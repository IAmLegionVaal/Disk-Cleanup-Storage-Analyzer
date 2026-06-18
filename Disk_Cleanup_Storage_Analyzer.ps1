#requires -Version 5.1
<#
.SYNOPSIS
    Disk Storage Analyzer.
.DESCRIPTION
    Read-only storage reporting toolkit for Windows support. It reports drive usage and folder size estimates.
#>
[CmdletBinding()]
param([string]$ScanPath = 'C:\Users',[string]$OutputPath,[int]$Top = 20)

$RunStamp = Get-Date -Format 'yyyyMMdd_HHmmss'
if ([string]::IsNullOrWhiteSpace($OutputPath)) { $OutputPath = Join-Path ([Environment]::GetFolderPath('Desktop')) 'Storage_Analyzer_Reports' }
New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null

function Convert-Size { param([double]$Bytes) if($Bytes -ge 1GB){'{0:N2} GB' -f ($Bytes/1GB)} elseif($Bytes -ge 1MB){'{0:N2} MB' -f ($Bytes/1MB)} else {'{0:N0} KB' -f ($Bytes/1KB)} }
function Get-FolderSize { param([string]$Path) try { (Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum } catch { 0 } }
function Export-Data { param($Name,$Data) $Data | Export-Csv (Join-Path $OutputPath "$Name.csv") -NoTypeInformation -Encoding UTF8; $Data | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $OutputPath "$Name.json") -Encoding UTF8 }

$drives = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
    [PSCustomObject]@{Drive=$_.DeviceID;Volume=$_.VolumeName;Size=Convert-Size $_.Size;Free=Convert-Size $_.FreeSpace;FreePercent=[math]::Round(($_.FreeSpace/$_.Size)*100,1);FileSystem=$_.FileSystem}
}
Export-Data -Name "drive_summary_$RunStamp" -Data $drives

$folderRows = @()
if (Test-Path $ScanPath) {
    Get-ChildItem -Path $ScanPath -Directory -Force -ErrorAction SilentlyContinue | ForEach-Object {
        $bytes = Get-FolderSize -Path $_.FullName
        $folderRows += [PSCustomObject]@{Path=$_.FullName;SizeBytes=$bytes;Size=Convert-Size $bytes;LastWriteTime=$_.LastWriteTime}
    }
}
$largest = $folderRows | Sort-Object SizeBytes -Descending | Select-Object -First $Top
Export-Data -Name "largest_folders_$RunStamp" -Data $largest

$html = "<h1>Storage Analyzer - $env:COMPUTERNAME</h1><p>Generated $(Get-Date)</p><h2>Drive Summary</h2>$($drives | ConvertTo-Html -Fragment)<h2>Largest Folders</h2>$($largest | ConvertTo-Html -Fragment)"
$html | ConvertTo-Html -Title 'Storage Analyzer' | Set-Content (Join-Path $OutputPath "storage_analyzer_$RunStamp.html") -Encoding UTF8
$largest | Format-Table -AutoSize
Write-Host "Reports saved to: $OutputPath" -ForegroundColor Green
Start-Process explorer.exe -ArgumentList "`"$OutputPath`"" -ErrorAction SilentlyContinue
