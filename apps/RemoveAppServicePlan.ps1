$ApplicationId = "qrpayments"

$ResourceGroupName = "TeamDragons_rg"
$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction Stop

# Azure resources to be removed
$AppServicePlanName = $ApplicationId + "serviceplan"

Write-Host "1. Get App Service Plan to be removed"
$AppServicePlan = Get-AzAppServicePlan -ResourceGroupName $ResourceGroupName -Name $AppServicePlanName -ErrorAction SilentlyContinue
if ($null -eq $AppServicePlan) {
    Write-Host "App Service Plan not found: $($AppServicePlanName)"
    return
}

Write-Host "Removing App Service Plan: $($AppServicePlan.Name)"
Remove-AzAppServicePlan -ResourceGroupName $ResourceGroup.ResourceGroupName -Name $AppServicePlanName -Force -ErrorAction Stop
Write-Host "Operation executed successfully"
