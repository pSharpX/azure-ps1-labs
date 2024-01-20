$ApplicationId = "qrpayments"
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

# Azure resources to be created
$IdentityName = $ApplicationId + "identity"

Write-Host "1. Get or Create User-Assigned Identity (Managed Identity)"
$ManagedIdentity = Get-AzUserAssignedIdentity -ResourceGroupName $ResourceGroupName -Name $IdentityName -ErrorAction SilentlyContinue
if ($null -eq $ManagedIdentity) {
    Write-Host "Creating new User-Assigned Identity.."
    $ManagedIdentity = New-AzUserAssignedIdentity -ResourceGroupName $ResourceGroupName -Name $IdentityName -Location $Location -Tag $Tags
}

Write-Host "User-Assigned Identity ID: $($ManagedIdentity.Id)"
Write-Host "User-Assigned Identity Principal ID: $($ManagedIdentity.PrincipalId)"
Write-Host "User-Assigned Identity Type: $($ManagedIdentity.Type)"