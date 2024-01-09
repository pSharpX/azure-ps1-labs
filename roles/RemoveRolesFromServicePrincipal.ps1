Disable-AzContextAutosave
Connect-AzAccount

$ApplicationId = "QrPayments"

Write-Host "Remove Service Principal Roles"
$ServicePrincipalName = "$($ApplicationId)App"
$ServicePrincipal = Get-AzADServicePrincipal -DisplayName $ServicePrincipalName
if ($null -eq $ServicePrincipal) {
    Write-Host "Service Principal ($($ServicePrincipalName)) not found"
    return
}

$ServicePrincipalId = $ServicePrincipal.Id
$ServicePrincipalAppId = $ServicePrincipal.AppId
Write-Host "Service Principal ID: $($ServicePrincipalId)"
Write-Host "Service Principal Name: $($ServicePrincipal.ServicePrincipalName)"
Write-Host "Service Principal DisplayName: $($ServicePrincipal.DisplayName)"
Write-Host "Service Principal Type: $($ServicePrincipal.ServicePrincipalType)"
Write-Host "Service Principal Application ID: $($ServicePrincipalAppId)"
Write-Host "Service Principal Secret: $($ServicePrincipal.PasswordCredentials.SecretText)"

#$AssignedRole = Get-AzRoleAssignment -ServicePrincipalName $ServicePrincipalAppId
#$AssignedRole = Get-AzRoleAssignment -ServicePrincipalName $ServicePrincipal.ServicePrincipalName[0]
$AssignedRole = Get-AzRoleAssignment -ObjectId $ServicePrincipalId
if ($null -eq $AssignedRole) {
    Write-Host "No roles were found for SP ($($ServicePrincipalName))"
    return
}

Write-Host "Role Assignment ID: $($AssignedRole.RoleAssignmentId)"
Write-Host "Role Assignment Name: $($AssignedRole.RoleAssignmentName)"
Write-Host "Role Definition ID: $($AssignedRole.RoleDefinitionId)"
Write-Host "Role Definition Name: $($AssignedRole.RoleDefinitionName)"

$Scope = $AssignedRole.Scope
$RoleDefinitionId = $AssignedRole.RoleDefinitionId
$Role = Get-AzRoleDefinition -Id $RoleDefinitionId

Write-Host "Removing Role ({$($Role.Id):$($Role.Name)}) from Service Principal ({$($ServicePrincipal.DisplayName):$($ServicePrincipalId)})"
Remove-AzRoleAssignment -ObjectId $ServicePrincipalId -RoleDefinitionId $Role.Id -Scope $Scope
Write-Host "Role removed successfully"

Disconnect-AzAccount