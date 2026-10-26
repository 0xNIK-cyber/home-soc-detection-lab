Set-ADDefaultDomainPasswordPolicy -Identity novatech.local `
    -MinPasswordLength 12 -ComplexityEnabled $true `
    -LockoutThreshold 5 `
    -LockoutDuration 00:15:00 -LockoutObservationWindow 00:15:00
Get-ADDefaultDomainPasswordPolicy