$ApplicationId = "qrpayments"

$ResourceGroupName = "TeamDragons_rg"
# Azure resources to be retrieved
$IdentityName = $ApplicationId + "identity"

Write-Host "1. Get User-Assigned Identity and associated resources"
$ManagedIdentity = Get-AzUserAssignedIdentity -ResourceGroupName $ResourceGroupName -Name $IdentityName -ErrorAction SilentlyContinue
if ($null -ne $ManagedIdentity) {
    Write-Host "User-Assigned Identity ID: $($ManagedIdentity.Id)"
    Write-Host "User-Assigned Identity Principal ID: $($ManagedIdentity.PrincipalId)"
    Write-Host "User-Assigned Identity Type: $($ManagedIdentity.Type)"

    Write-Host "Listing Resources associated to Identity"
    $Resources = Get-AzUserAssignedIdentityAssociatedResource -ResourceGroupName $ResourceGroupName -Name $ManagedIdentity.Name -ErrorAction SilentlyContinue
    if ($null -ne $Resources) {
        foreach ($Resource in $Resources) {
            Write-Host "User-Assigned Identity ID: $($ManagedIdentity.Id)"
            Write-Host "User-Assigned Identity Principal ID: $($ManagedIdentity.PrincipalId)"
            Write-Host "User-Assigned Identity Type: $($ManagedIdentity.Type)"
        }
    }
}
