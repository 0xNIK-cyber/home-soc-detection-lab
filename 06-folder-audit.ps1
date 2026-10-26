foreach ($d in "Finance","HR") {
    $path = "C:\Shares\$d"
    $acl  = Get-Acl $path -Audit
    $rule = New-Object System.Security.AccessControl.FileSystemAuditRule(
        "Everyone", "ReadData,WriteData,Delete",
        "ContainerInherit,ObjectInherit", "None", "Success,Failure")
    $acl.AddAuditRule($rule)
    Set-Acl -Path $path -AclObject $acl
}