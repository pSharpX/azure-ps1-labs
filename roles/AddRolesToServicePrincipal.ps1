Disable-AzContextAutosave
Connect-AzAccount

$ApplicationId = "QrPayments"

Write-Host "Get or Create new Service Principal"
$ServicePrincipalName = "$($ApplicationId)App"
$ServicePrincipal = Get-AzADServicePrincipal -DisplayName $ServicePrincipalName
if ($null -eq $ServicePrincipal) {
    Write-Host "Service Principal not found. $($ServicePrincipalName) SP will be created"
    $ServicePrincipal = New-AzADServicePrincipal -DisplayName $ServicePrincipalName
}

$ServicePrincipalId = $ServicePrincipal.Id
$ServicePrincipalAppId = $ServicePrincipal.AppId
$ServicePrincipalSecret = $ServicePrincipal.PasswordCredentials.SecretText

Write-Host "Service Principal ID: $($ServicePrincipalId)"
Write-Host "Service Principal Application ID: $($ServicePrincipalAppId)"
Write-Host "Service Principal Secret: $($ServicePrincipalSecret)"

$SubscriptionName = "AS_BASIC"
$Subscription = Get-AzSubscription -SubscriptionName $SubscriptionName
$Scope = "/subscriptions/$Subscription"
$RoleDefinitionName = "Contributor"
$Role = Get-AzRoleDefinition -Name $RoleDefinitionName

Write-Host "Assigning Role ({$($Role.Id):$($Role.Name)}) to Service Principal ({$($ServicePrincipal.DisplayName):$($ServicePrincipalId)})"
New-AzRoleAssignment -ObjectId $ServicePrincipalId -RoleDefinitionId $Role.Id -Scope $Scope
Write-Host "Role assigned successfully"

Disconnect-AzAccount