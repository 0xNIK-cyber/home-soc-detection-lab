$first = "Avi","Noa","Yossi","Tamar","Eli","Shira","Omer","Dana","Itai","Lior"
$last  = "Mizrahi","Biton","Friedman","Shalom","Azulay","Klein","Dahan","Golan"

1..50 | ForEach-Object {
    [pscustomobject]@{
        ClientID = 1000 + $_
        Name     = "$(Get-Random $first) $(Get-Random $last)"
        Phone    = "000-" + (Get-Random -Minimum 1000000 -Maximum 9999999)
        Balance  = Get-Random -Minimum 1000 -Maximum 250000
    }
} | Export-Csv "C:\Shares\Finance\clients.csv" -NoTypeInformation -Encoding UTF8

Get-ADUser -Filter * -SearchBase "OU=NovaTech,DC=novatech,DC=local" -Properties Department,Title |
    Select-Object Name, SamAccountName, Department, Title,
        @{n="Salary";e={Get-Random -Minimum 9000 -Maximum 30000}} |
    Export-Csv "C:\Shares\HR\employees.csv" -NoTypeInformation -Encoding UTF8