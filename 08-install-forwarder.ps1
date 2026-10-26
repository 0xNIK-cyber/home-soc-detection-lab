$msi = (Get-ChildItem C:\Lab\tools\splunkforwarder-*.msi).FullName
Start-Process msiexec.exe -Wait -ArgumentList "/i `"$msi`" RECEIVING_INDEXER=`"10.10.10.20:9997`" AGREETOLICENSE=Yes SPLUNKUSERNAME=admin SPLUNKPASSWORD=admin1234 USE_LOCAL_SYSTEM=1 /quiet"

$inputs = @"
[WinEventLog://Security]
disabled = 0
index = wineventlog
renderXml = false

[WinEventLog://System]
disabled = 0
index = wineventlog
renderXml = false

[WinEventLog://Microsoft-Windows-Sysmon/Operational]
disabled = 0
index = sysmon
renderXml = true
"@
Set-Content -Path "C:\Program Files\SplunkUniversalForwarder\etc\system\local\inputs.conf" -Value $inputs -Encoding ASCII

Restart-Service SplunkForwarder
Get-Service SplunkForwarder