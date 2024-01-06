Disable-AzContextAutosave
Connect-AzAccount

$ApplicationId = "QrPayments"

Write-Host "Remove existent Service Principal"
$ServicePrincipalName = "$($ApplicationId)App"
$ServicePrincipal = Get-AzADServicePrincipal -DisplayName $ServicePrincipalName
if ($null -eq $ServicePrincipal) {
    Write-Host "Service Principal ($ServicePrincipalName) not found."
    return
}

$ServicePrincipalId = $ServicePrincipal.Id
$ServicePrincipalAppId = $ServicePrincipal.AppId

Write-Host "Removing Service Principal"
Write-Host "Service Principal ID: $($ServicePrincipalId)"
Write-Host "Service Principal Application ID: $($ServicePrincipalAppId)"

Remove-AzADServicePrincipal -DisplayName $ServicePrincipal.DisplayName

Disconnect-AzAccount