$ApplicationId = "qrpayments"
$ResourceGroupName = "TeamDragons_rg"
$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction Break

Write-Host "Get existent Key Vault"
$KeyVaultName = "kv" + $ApplicationId
$AccessPoliciesProps = @{
    ObjectId = "your_object_id"
}
$KeyVault = Get-AzKeyVault -ResourceGroupName $ResourceGroup.ResourceGroupName -VaultName $KeyVaultName -ErrorAction SilentlyContinue
if ($null -eq $KeyVault) {
    Write-Host "Key Vault not found: $($KeyVaultName)"
    return
}

Remove-AzKeyVaultAccessPolicy @AccessPoliciesProps -VaultName $KeyVault.VaultName -ErrorAction Break
Write-Host "Access Policies removed"
