$root = "OU=NovaTech,DC=novatech,DC=local"
$pw = ConvertTo-SecureString "NovaUser!2026" -AsPlainText -Force

$users = @(
    @{Sam="d.levi";   First="Daniel"; Last="Levi";     Dept="IT";      Title="IT Administrator"},
    @{Sam="m.cohen";  First="Michal"; Last="Cohen";    Dept="IT";      Title="Helpdesk Technician"},
    @{Sam="r.amar";   First="Ron";    Last="Amar";     Dept="Finance"; Title="Accountant"},
    @{Sam="s.peretz"; First="Sara";   Last="Peretz";   Dept="Finance"; Title="Finance Manager"},
    @{Sam="m.ben";    First="Maya";   Last="Ben-David";Dept="HR";      Title="HR Manager"},
    @{Sam="y.katz";   First="Yossi";  Last="Katz";     Dept="HR";      Title="Recruiter"}
)

foreach ($u in $users) {
    New-ADUser -SamAccountName $u.Sam -Name "$($u.First) $($u.Last)" `
        -GivenName $u.First -Surname $u.Last `
        -UserPrincipalName "$($u.Sam)@novatech.local" `
        -Department $u.Dept -Title $u.Title -Company "NovaTech" `
        -Path "OU=Users,OU=$($u.Dept),$root" `
        -AccountPassword $pw -Enabled $true
    Add-ADGroupMember -Identity "GRP-$($u.Dept)" -Members $u.Sam
}