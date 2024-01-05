$ApplicationId = "qrpayments"
$ResourceGroupName = "TeamDragons_rg"
$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction Stop

Write-Host "Get existent Key Vault"
$KeyVaultName = "kv" + $ApplicationId
$AccessPoliciesProps = @{
    ObjectId = "your_object_id"
    PermissionsToKeys =  @("All")
    PermissionsToSecrets = @("List", "Set")
    PermissionsToCertificates = @()
}
$KeyVault = Get-AzKeyVault -ResourceGroupName $ResourceGroup.ResourceGroupName -VaultName $KeyVaultName -ErrorAction SilentlyContinue
if ($null -eq $KeyVault) {
    Write-Host "Key Vault not found: $($KeyVaultName)"
    return
}

Set-AzKeyVaultAccessPolicy @AccessPoliciesProps -VaultName $KeyVault.VaultName -BypassObjectIdValidation -ErrorAction Stop
Write-Host "Key Vault's Access Policies updated: $($KeyVault.VaultName)"

<#

PermissionsToCertificates
Specifies an array of certificate permissions to grant to a user or service principal. 'All' will grant all the permissions except 'Purge' The acceptable values for this parameter:

    All
    Get
    List
    Delete
    Create
    Import
    Update
    Managecontacts
    Getissuers
    Listissuers
    Setissuers
    Deleteissuers
    Manageissuers
    Recover
    Backup
    Restore
    Purge

PermissionsToKeys
Specifies an array of key operation permissions to grant to a user or service principal. 'All' will grant all the permissions except 'Purge' The acceptable values for this parameter:

    All
    Decrypt
    Encrypt
    UnwrapKey
    WrapKey
    Verify
    Sign
    Get
    List
    Update
    Create
    Import
    Delete
    Backup
    Restore
    Recover
    Purge
    Rotate

PermissionsToSecrets
Specifies an array of secret operation permissions to grant to a user or service principal. 'All' will grant all the permissions except 'Purge' The acceptable values for this parameter:

    All
    Get
    List
    Set
    Delete
    Backup
    Restore
    Recover
    Purge

#>