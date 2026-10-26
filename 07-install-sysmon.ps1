$t = "C:\Lab\tools"
Expand-Archive "$t\Sysmon.zip" -DestinationPath "$t\Sysmon" -Force
Expand-Archive "$t\sysmon-modular-master.zip" -DestinationPath "$t" -Force
$config = Get-ChildItem "$t" -Recurse -Filter "sysmonconfig.xml" | Select-Object -First 1
& "$t\Sysmon\Sysmon64.exe" -accepteula -i $config.FullName
Get-Service Sysmon64
Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents 5 | Format-Table TimeCreated, Id, Message -Wrap