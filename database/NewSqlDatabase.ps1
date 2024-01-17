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

# Azure resources to be created
$SqlServerName = $ApplicationId + "sqlserver"
$SqlDatabaseName = $ApplicationId + "database"

Write-Host "1. Get existent SQL Server"
$SqlServer = Get-AzSqlServer -ResourceGroupName $ResourceGroupName -ServerName $SqlServerName -ErrorAction SilentlyContinue
if ($null -eq $SqlServer) {
    Write-Host "SQL Server not found: $SqlServerName"
    return
}

Write-Host "SQL Server: $($SqlServer.ServerName)"
$CommonProps = @{
    ResourceGroupName = $ResourceGroup.ResourceGroupName
    DatabaseName  = $SqlDatabaseName
    ServerName = $SqlServer.ServerName
    Edition = "GeneralPurpose" # Free, Basic, Standard, Premiun, GeneralPurpose
    ComputeModel = "Provisioned" # Serverless
    VCore = 2
    ComputeGeneration = "Gen5"
    Tags = $Tags
}

Write-Host "1. Get or Create new SQL Database"
$SqlDatabase = Get-AzSqlDatabase -ResourceGroupName $ResourceGroupName -ServerName $SqlDatabaseName -ErrorAction SilentlyContinue
if ($null -eq $SqlDatabase) {
    Write-Host "Creating new SQL Database.."
    $SqlDatabase = New-AzSqlDatabase @CommonProps
}

Write-Host "SQL Server: $($SqlDatabase.DatabaseName)"
