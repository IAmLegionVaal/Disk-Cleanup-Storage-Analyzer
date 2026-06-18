# Disk Cleanup Storage Analyzer

A diagnostic PowerShell toolkit for storage triage and cleanup planning.

## Features

- Drive free-space summary
- Largest folders under selected paths
- User profile size summary
- Common cache and temp location size estimates
- Recycle Bin size estimate
- Windows component store size context
- CSV, JSON, and HTML reporting

## How to run

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\Disk_Cleanup_Storage_Analyzer.ps1
```

Analyze a custom path:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\Disk_Cleanup_Storage_Analyzer.ps1 -ScanPath C:\Users
```

## Safety

This script is analyzer-only. It reports storage usage and does not remove files.

## Suggested topics

```text
powershell
windows
storage
disk-cleanup
helpdesk
it-support
sysadmin
```
