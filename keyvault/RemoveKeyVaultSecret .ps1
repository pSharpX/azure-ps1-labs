$ApplicationId = "qrpayments"
$ResourceGroupName = "TeamDragons_rg"
$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction Stop

Write-Host "Get existent Key Vault"
$KeyVaultName = "kv" + $ApplicationId
$KeyVault = Get-AzKeyVault -ResourceGroupName $ResourceGroup.ResourceGroupName -VaultName $KeyVaultName -ErrorAction SilentlyContinue
if ($null -eq $KeyVault) {
    Write-Host "Key Vault not found: $($KeyVaultName)"
    return
}

Write-Host "Key Vault Resource: $($KeyVault.VaultName)"
Write-Host "Remove existent Secrets from Key Vault"

$Secrets = @("ansible-username")
foreach ($SecretName in $Secrets) {
    Write-Host "Secret to be removed: $SecretName"
    $Secret = Get-AzKeyVaultSecret -VaultName $KeyVault.VaultName -Name $SecretName -ErrorAction SilentlyContinue
    if ($null -ne $Secret) {
        Remove-AzKeyVaultSecret -VaultName $KeyVault.VaultName -Name $SecretName -Force
        Write-Host "Secret removed: $($Secret.Name)"
    }
}