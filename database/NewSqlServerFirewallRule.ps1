$ApplicationId = "qrpayments"

$ResourceGroupName = "TeamDragons_rg"
$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction Stop

# Azure resources to be created
$SqlServerName = $ApplicationId + "sqlserver"

Write-Host "1. Get Sql Server"
$SqlServer = Get-AzSqlServer -ResourceGroupName $ResourceGroupName -ServerName $SqlServerName -ErrorAction Stop

$CommonPropsList = @(
    @{
        ResourceGroupName = $ResourceGroup.ResourceGroupName
        ServerName = $SqlServer.ServerName
        FirewallRuleName = "Allow-AllAzureServices"
        StartIpAddress = "0.0.0.0"
        EndIpAddress = "0.0.0.0"
    }
    @{
        ResourceGroupName = $ResourceGroup.ResourceGroupName
        ServerName = $SqlServer.ServerName
        FirewallRuleName = "Allow-MyIp"
        StartIpAddress = "your_ip_address"
        EndIpAddress = "your_ip_address"
    }
)

Write-Host "2. Get or Create new SQL Server Firewall rule"
foreach ($CommonProps in $CommonPropsList) {
    $SqlServerFirewallRule = Get-AzSqlServerFirewallRule -ResourceGroupName $ResourceGroupName -ServerName $SqlServerName -FirewallRuleName $CommonProps.FirewallRuleName -ErrorAction SilentlyContinue
    if ($null -eq $SqlServerFirewallRule) {
        Write-Host "Creating new SQL Server.."
        $SqlServerFirewallRule = New-AzSqlServerFirewallRule @CommonProps
    }
    Write-Host "Firewall Rule: $($SqlServerFirewallRule.FirewallRuleName)"
}
