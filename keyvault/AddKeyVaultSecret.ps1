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

Write-Host "Get or Create Key Vault"
$KeyVaultName = "kv" + $ApplicationId
$KeyVault = Get-AzKeyVault -ResourceGroupName $ResourceGroup.ResourceGroupName -VaultName $KeyVaultName -ErrorAction SilentlyContinue
if ($null -eq $KeyVault) {
    Write-Host "Key Vault not found: $($KeyVaultName)"
    return
}

Write-Host "Key Vault Resource: $($KeyVault.VaultName)"
Write-Host "Adding new Secrets to Key Vault:"

$Expires = (Get-Date).AddDays(2).ToUniversalTime()
$NBF = (Get-Date).ToUniversalTime()
$Secrets = @(
    @{
        Name = "db-password"
        Value = ConvertTo-SecureString -String "this_is_my_database_password" -AsPlainText -Force
    }
    @{
        Name = "store-key"
        Value = ConvertTo-SecureString -String "this_is_my_storekey_password" -AsPlainText -Force
    }
    @{
        Name = "client-secret"
        Value = ConvertTo-SecureString -String "this_is_my_client_secret" -AsPlainText -Force
    }
)

foreach ($Secret in $Secrets) {
    Set-AzKeyVaultSecret -VaultName $KeyVault.VaultName -Name $Secret.Name -SecretValue $Secret.Value -Expires $Expires -NotBefore $NBF -Tag $Tags -ErrorAction Stop
    Write-Host "Secret added: $($Secret.Name)"
}