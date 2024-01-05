$ApplicationId = "qrpayments"

$ResourceGroupName = "TeamDragons_rg"
$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction Break

Write-Host "Remove existent Key Vault"
$KeyVaultName = "kv" + $ApplicationId

$KeyVault = Get-AzKeyVault -ResourceGroupName $ResourceGroup.ResourceGroupName -VaultName $KeyVaultName -ErrorAction SilentlyContinue
if ($null -eq $KeyVault) {
    Write-Host "No key Vault was found: $($KeyVaultName)"
    return
}

Write-Host "Removing key Vault: $($KeyVault.VaultName)"
Remove-AzKeyVault -VaultName $KeyVaultName -ResourceGroupName $ResourceGroup.ResourceGroupName -Force
Write-Host "Key Vault removed"
#Remove-AzKeyVault -VaultName ContosoVault -InRemovedState -Location westus