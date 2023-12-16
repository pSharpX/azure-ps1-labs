$ApplicationId = "qrpayments"
$Tags = @{
    Provisioner = "PowerShell"
    Environment = "Development"
    "Technical-Owner" = "TeamDragons"
    "Application-Id" = $ApplicationId
    "Data-Classification" = "Classified"
}

$ResourceGroupName = "TeamDragons_rg"
$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName
$Location = $ResourceGroup.Location

$PublicIPName = "pip" + $ApplicationId
$CommonProps = @{
    ResourceGroupName = $ResourceGroupName
    Location = $Location
    Tag = $Tags
}

$PublicIPAddress = Get-AzPublicIpAddress -Name $PublicIPName -ResourceGroupName $ResourceGroupName
if ($null -eq $PublicIPAddress) {
    "Public IP Address not found: " + $PublicIPName
    $PublicIPAddress = New-AzPublicIpAddress @CommonProps -Name $PublicIPName -Sku "Standard" -AllocationMethod "Static"
    "Public IP Address crated: " + $PublicIPName
}

$NetworkInterfaceName = "nic" + $ApplicationId
$NetworkInterfaceIpConfigName = "ipconfig2"

$NetworkInterface = Get-AzNetworkInterface -Name $NetworkInterfaceName -ResourceGroupName $ResourceGroupName
$NetworkInterfaceIpConfigs = $NetworkInterface | Get-AzNetworkInterfaceIpConfig

$NetworkInterfaceDefualtIpConfig = $NetworkInterface | Get-AzNetworkInterfaceIpConfig -Name $NetworkInterfaceIpConfigName
$NetworkInterfacePrimaryIpConfig = $NetworkInterfaceIpConfigs | Where-Object Primary -eq $true

"Default Ip Config: " + $NetworkInterfaceDefualtIpConfig.Id
"Primary Ip Config: " + $NetworkInterfacePrimaryIpConfig.Id
"Available Ip Configs: " + ($NetworkInterfaceIpConfigs | Select-Object -ExpandProperty Name)

"Assigning Public IP Address ($PublicIPAddress.Name) to Network Interface Ip Config ($NetworkInterfacePrimaryIpConfig.Name)"
$NetworkInterface | Set-AzNetworkInterfaceIpConfig -Name $NetworkInterfacePrimaryIpConfig.Name -PublicIpAddress $PublicIPAddress
"Updating Network Interface ($NetworkInterface.Name)"
$NetworkInterface | Set-AzNetworkInterface
