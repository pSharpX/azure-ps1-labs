$ApplicationId = "qrpayments"

$ResourceGroupName = "TeamDragons_rg"
$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction Stop

# Azure resources to be removed
$SqlServerName = $ApplicationId + "sqlserver"
$SqlDatabaseName = $ApplicationId + "database"

Write-Host "1. Get Sql Database to be removed"
$SqlDatabase = Get-AzSqlDatabase -ResourceGroupName $ResourceGroupName -ServerName $SqlServerName -DatabaseName $SqlDatabaseName -ErrorAction SilentlyContinue
if ($null -eq $SqlDatabase) {
    Write-Host "Sql Database not found: $($SqlDatabaseName)"
    return
}

Write-Host "Removing Sql Database: $($SqlDatabase.DatabaseName)"
Remove-AzSqlDatabase -ResourceGroupName $ResourceGroup.ResourceGroupName -ServerName $SqlServerName  -DatabaseName $SqlDatabase.DatabaseName -Force -ErrorAction Stop
Write-Host "Operation executed successfully"

