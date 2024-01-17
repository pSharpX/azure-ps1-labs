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
$SqlServerName = $ApplicationId + "sqlserver"
$AdminUser = "crivera"
$AdminPassSecure = "Azure@123" | ConvertTo-SecureString -AsPlainText -Force
$Credentials = New-Object System.Management.Automation.PSCredential ($AdminUser, $AdminPassSecure)

$CommonProps = @{
    ResourceGroupName = $ResourceGroup.ResourceGroupName
    Location = $Location
    ServerName = $SqlServerName
    ServerVersion = "12.0"
    SqlAdministratorCredentials = $Credentials
    Tags = $Tags
}

Write-Host "1. Get or Create new SQL Server"
$SqlServer = Get-AzSqlServer -ResourceGroupName $ResourceGroupName -ServerName $SqlServerName -ErrorAction SilentlyContinue
if ($null -eq $SqlServer) {
    Write-Host "Creating new SQL Server.."
    $SqlServer = New-AzSqlServer @CommonProps
}

Write-Host "SQL Server: $($SqlServer.ServerName)"
Write-Host "SQL Server FQDN: $($SqlServer.FullyQualifiedDomainName)"
