Disable-AzContextAutosave
Connect-AzAccount

$SubscriptionName = "AS_BASIC"
$Subscription = Get-AzSubscription -SubscriptionName $SubscriptionName
Write-Host "Subscription ID: $($Subscription.Id)"
Write-Host "Subscription Name: $($Subscription.Name)"
Write-Host "Tenant ID: $($Subscription.TenantId)"
$Subscription