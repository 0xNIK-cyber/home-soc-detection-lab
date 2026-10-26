New-ADOrganizationalUnit -Name "NovaTech" -Path "DC=novatech,DC=local"
$root = "OU=NovaTech,DC=novatech,DC=local"

foreach ($d in "IT","Finance","HR") {
    New-ADOrganizationalUnit -Name $d -Path $root
    New-ADOrganizationalUnit -Name "Users"     -Path "OU=$d,$root"
    New-ADOrganizationalUnit -Name "Computers" -Path "OU=$d,$root"
    New-ADGroup -Name "GRP-$d" -GroupScope Global -GroupCategory Security -Path "OU=$d,$root"
}