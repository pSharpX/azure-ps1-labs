$ApplicationId = "qrpayments"
$Tags = @{
    Provisioner = "PowerShell"
    Environment = "Development"
    "Technical-Owner" = "TeamDragons"
    "Application-Id" = $ApplicationId
    "Data-Classification" = "Restricted"
}

$ResourceGroupName = "TeamDragons_rg"
$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction Break
$Location = $ResourceGroup.Location

Write-Host "Get or Create Key Vault"
$KeyVaultName = "kv" + $ApplicationId
$CommonProps = @{
    Name = $KeyVaultName
    ResourceGroupName = $ResourceGroupName
    Location = $Location
    Sku = "Standard"
    SoftDeleteRetentionInDays = 7
    EnabledForDeployment = $true
    EnabledForTemplateDeployment = $true
    Tag = $Tags
}
$KeyVault = Get-AzKeyVault -ResourceGroupName $ResourceGroupName -VaultName $KeyVaultName -ErrorAction SilentlyContinue
if ($null -eq $KeyVault) {
    Write-Host "Creating new key Vault: $($KeyVaultName)"
    $KeyVault = New-AzKeyVault @CommonProps
}

Write-Host "Key Vault Resource: $($KeyVault.VaultName)"