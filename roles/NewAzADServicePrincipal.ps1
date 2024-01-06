Disable-AzContextAutosave
Connect-AzAccount

$ApplicationId = "QrPayments"
$Tags = @{
    Provisioner = "PowerShell"
    Environment = "Development"
    "Technical-Owner" = "TeamDragons"
    "Application-Id" = $ApplicationId
    "Data-Classification" = "Restricted"
}

Write-Host "Get or Create new Service Principal"
$ServicePrincipalName = "$($ApplicationId)App"
$ServicePrincipal = Get-AzADServicePrincipal -DisplayName $ServicePrincipalName
if ($null -eq $ServicePrincipal) {
    Write-Host "Service Principal not found. $($ServicePrincipalName) SP will be created"
    $ServicePrincipal = New-AzADServicePrincipal -DisplayName $ServicePrincipalName -Tag $Tags
}

$ServicePrincipalId = $ServicePrincipal.Id
$ServicePrincipalAppId = $ServicePrincipal.AppId
$ServicePrincipalSecret = $ServicePrincipal.PasswordCredentials.SecretText

Write-Host "Service Principal ID: $($ServicePrincipalId)"
Write-Host "Service Principal Application ID: $($ServicePrincipalAppId)"
Write-Host "Service Principal Secret: $($ServicePrincipalSecret)"

Disconnect-AzAccount