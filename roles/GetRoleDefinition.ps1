Write-Host "Search for Role Definitions"

$RoleDefinitionName = "Contributor"
$RoleDefinitionId = "ba92f5b4-2d11-453d-a403-e96b0029c9fe"
$ContributorRole = Get-AzRoleDefinition -Name $RoleDefinitionName
$StorageBDContributorRole = Get-AzRoleDefinition -Id $RoleDefinitionId

Write-Host "Role ID: $($ContributorRole.Id)"
Write-Host "Role Name: $($ContributorRole.Name)"

Write-Host "Role ID: $($StorageBDContributorRole.Id)"
Write-Host "Role Name: $($StorageBDContributorRole.Name)"

<##
Roles and Permissions
(https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles)

Contributor - b24988ac-6180-42a0-ab88-20f7382dd24c - Grants full access to manage all resources, but does not allow you to assign roles in Azure RBAC, manage assignments in Azure Blueprints, or share image galleries.
Storage Blob Data Contributor - ba92f5b4-2d11-453d-a403-e96b0029c9fe - Read, write, and delete Azure Storage containers and blobs
AcrPull - 7f951dda-4ed3-4680-a7ca-43fe172d538d - Pull artifacts from a container registry
AcrPush - 8311e382-0749-4cb8-b61a-304f252e45ec - Push artifacts to or pull artifacts from a container registry.
Key Vault Contributor - f25e0fa2-a7c8-4377-a976-54943a77a395 - Manage key vaults, but does not allow you to assign roles in Azure RBAC, and does not allow you to access secrets, keys, or certificates.

##>