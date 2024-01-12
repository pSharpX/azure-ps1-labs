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

$ResourceGroupName = "TeamDragons_rg"
$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction Stop
$Location = $ResourceGroup.Location

Write-Host "1. Get or Create Key Vault"
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

Write-Host "2. Get or Create new Service Principal"
$ServicePrincipalName = "$($ApplicationId)App"
$ServicePrincipal = Get-AzADServicePrincipal -DisplayName $ServicePrincipalName
if ($null -eq $ServicePrincipal) {
    Write-Host "Service Principal not found. $($ServicePrincipalName) SP will be created"
    $ServicePrincipal = New-AzADServicePrincipal -DisplayName $ServicePrincipalName -Tag $Tags
}
$ServicePrincipalId = $ServicePrincipal.Id
$ServicePrincipalAppId = $ServicePrincipal.AppId

Write-Host "Service Principal ID: $($ServicePrincipalId)"
Write-Host "Service Principal Name: $($ServicePrincipal.ServicePrincipalName)"
Write-Host "Service Principal DisplayName: $($ServicePrincipal.DisplayName)"
Write-Host "Service Principal Type: $($ServicePrincipal.ServicePrincipalType)"
Write-Host "Service Principal Application ID: $($ServicePrincipalAppId)"


Write-Host "3. Assign Contributor Role to SP"
$SubscriptionName = "AS_BASIC"
$Subscription = Get-AzSubscription -SubscriptionName $SubscriptionName
$Scope = "/subscriptions/$Subscription"
$RoleDefinitionName = "Contributor"
$Role = Get-AzRoleDefinition -Name $RoleDefinitionName

$AssignedRole = Get-AzRoleAssignment -ObjectId $ServicePrincipalId -RoleDefinitionId $Role.Id -Scope $Scope -ErrorAction SilentlyContinue
if ($null -eq $AssignedRole) {
    Write-Host "No roles were found for SP ($($ServicePrincipalName))"
    Write-Host "Assigning Role ({$($Role.Id):$($Role.Name)}) to Service Principal ({$($ServicePrincipal.DisplayName):$($ServicePrincipalId)})"
    New-AzRoleAssignment -ObjectId $ServicePrincipalId -RoleDefinitionId $Role.Id -Scope $Scope
    Write-Host "Role assigned successfully"
}


Write-Host "4. Add new Secrets to Key Vault"
$AppIdKeyName = "ansible-sp-appid"
$AppSecretKeyName = "ansible-sp-appsecret"
$Expires = (Get-Date).AddDays(5).ToUniversalTime()
$NBF = (Get-Date).ToUniversalTime()
$ServicePrincipalSecret = if ($null -ne $ServicePrincipal.PasswordCredentials.SecretText) {$ServicePrincipal.PasswordCredentials.SecretText} else {"temp"}
$Secrets = @(
    @{
        Name = $AppIdKeyName
        Value = $ServicePrincipal.AppId | ConvertTo-SecureString -AsPlainText -Force -ErrorAction Stop
    }
    @{
        Name = $AppSecretKeyName
        Value = $ServicePrincipalSecret | ConvertTo-SecureString -AsPlainText -Force -ErrorAction Stop
    }
)

foreach ($Secret in $Secrets) {
    $KeyVaultSecret = Get-AzKeyVaultSecret -VaultName $KeyVault.VaultName -Name $Secret.Name -ErrorAction SilentlyContinue
    if ($null -eq $KeyVaultSecret) {
        Set-AzKeyVaultSecret -VaultName $KeyVault.VaultName -Name $Secret.Name -SecretValue $Secret.Value -Expires $Expires -NotBefore $NBF -Tag $Tags -ErrorAction Stop
        Write-Host "Secret added: $($Secret.Name)"
    }
}
Write-Host "Secrets updated successfully"

Disconnect-AzAccount