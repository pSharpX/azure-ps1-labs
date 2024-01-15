$ApplicationId = "qrpayments"

$ResourceGroupName = "TeamDragons_rg"
$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction Stop


# Azure resources to be removed
$WebAppName = $ApplicationId + "webapp"

Write-Host "1. Get Web App to be removed"
$WebApp = Get-AzWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName -ErrorAction SilentlyContinue
if ($null -eq $WebApp) {
    Write-Host "Web App not found: $($WebAppName)"
    return
}

Write-Host "Removing Web App: $($WebApp.Name)"
Remove-AzWebApp -ResourceGroupName $ResourceGroup.ResourceGroupName -Name $WebApp.Name -Force -ErrorAction Stop
Write-Host "Operation executed successfully"

