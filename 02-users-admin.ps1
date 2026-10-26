$root = "OU=NovaTech,DC=novatech,DC=local"
$pw = ConvertTo-SecureString "NovaUser!2026" -AsPlainText -Force
New-ADUser -SamAccountName "adm.dlevi" -Name "Daniel Levi (Admin)" `
    -UserPrincipalName "adm.dlevi@novatech.local" -Department "IT" `
    -Path "OU=Users,OU=IT,$root" -AccountPassword $pw -Enabled $true
Add-ADGroupMember -Identity "Domain Admins" -Members "adm.dlevi"