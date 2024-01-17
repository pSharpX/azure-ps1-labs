$ApplicationId = "qrpayments"

$ResourceGroupName = "TeamDragons_rg"
$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction Stop

# Azure resources to be removed
$SqlServerName = $ApplicationId + "sqlserver"

Write-Host "1. Get Sql Server to be removed"
$SqlServer = Get-AzSqlServer -ResourceGroupName $ResourceGroupName -ServerName $SqlServerName -ErrorAction SilentlyContinue
if ($null -eq $SqlServer) {
    Write-Host "Sql Server not found: $($SqlServerName)"
    return
}

Write-Host "Removing Sql Server: $($SqlServer.ServerName)"
Remove-AzSqlServer -ResourceGroupName $ResourceGroup.ResourceGroupName -ServerName $SqlServer.ServerName -Force -ErrorAction Stop
Write-Host "Operation executed successfully"

