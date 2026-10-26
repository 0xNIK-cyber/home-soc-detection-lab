foreach ($d in "IT","Finance","HR") {
    $p = "C:\Shares\$d"
    New-Item -ItemType Directory -Path $p -Force | Out-Null
    icacls $p /inheritance:r /grant "Administrators:(OI)(CI)F" "SYSTEM:(OI)(CI)F" "NOVATECH\GRP-$($d):(OI)(CI)M"
    New-SmbShare -Name $d -Path $p -FullAccess "NOVATECH\GRP-$d","Administrators"
}