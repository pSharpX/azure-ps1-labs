$ApplicationId = "qrpayments"

$ResourceGroupName = "TeamDragons_rg"
$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction Stop
$SubscriptionName = "AS_BASIC"
$Subscription = Get-AzSubscription -SubscriptionName $SubscriptionName -ErrorAction Stop

# Azure resources to be retrieved
$IdentityName = $ApplicationId + "identity"

Write-Host "1. Get User-Assigned Identities by Suscription"
$ManagedIdentities1 = Get-AzUserAssignedIdentity -SubscriptionId $Subscription.SubscriptionId -ErrorAction SilentlyContinue
if ($null -ne $ManagedIdentities1) {
    Write-Host "Listing Identities in Subscription $($Subscription.Name)($($Subscription.SubscriptionId))"
    foreach ($ManagedIdentity in $ManagedIdentities1) {
        Write-Host "User-Assigned Identity ID: $($ManagedIdentity.Id)"
        Write-Host "User-Assigned Identity Principal ID: $($ManagedIdentity.PrincipalId)"
        Write-Host "User-Assigned Identity Type: $($ManagedIdentity.Type)"
    }
}


Write-Host "2. Get User-Assigned Identities by Resource Group"
$ManagedIdentities2 = Get-AzUserAssignedIdentity -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
if ($null -ne $ManagedIdentities1) {
    Write-Host "Listing Identities in Resource Group $($ResourceGroup.ResourceGroupName)($($ResourceGroup.ResourceId))"
    foreach ($ManagedIdentity in $ManagedIdentities2) {
        Write-Host "User-Assigned Identity ID: $($ManagedIdentity.Id)"
        Write-Host "User-Assigned Identity Principal ID: $($ManagedIdentity.PrincipalId)"
        Write-Host "User-Assigned Identity Type: $($ManagedIdentity.Type)"
    }
}

Write-Host "3. Get User-Assigned Identity"
$ManagedIdentity = Get-AzUserAssignedIdentity -ResourceGroupName $ResourceGroupName -Name $IdentityName -ErrorAction SilentlyContinue
if ($null -ne $ManagedIdentity) {
    Write-Host "User-Assigned Identity ID: $($ManagedIdentity.Id)"
    Write-Host "User-Assigned Identity Principal ID: $($ManagedIdentity.PrincipalId)"
    Write-Host "User-Assigned Identity Type: $($ManagedIdentity.Type)"
}
