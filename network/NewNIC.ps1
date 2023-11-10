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

$VirtualNetworkName = "vnet" + $ApplicationId
$SubnetName = "SubnetA"
$NetworkInterfaceName = "nic" + $ApplicationId

$CommonProps = @{
    Name = $NetworkInterfaceName
    ResourceGroupName = $ResourceGroup.ResourceGroupName
    Location = $Location
    Tag = $Tags
}

$VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName
$SubnetA = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VirtualNetwork

$IpConfigsProps = @(
    @{
        Name = "ipconfig1"
        PrivateIpAddressVersion = "IPv4"
        Primary = $True
    }
    @{
        Name = "ipconfig2"
        PrivateIpAddressVersion = "IPv4"
        Primary = $False
    }
    @{
        Name = "ipconfig3"
        PrivateIpAddressVersion = "IPv4"
        Primary = $False
    }
)

$IpConfigs = New-Object System.Collections.Generic.List[System.Object]
foreach ($IpConfigProps in $IpConfigsProps) {
    $IpConfig = New-AzNetworkInterfaceIpConfig @IpConfigProps -Subnet $SubnetA
    $IpConfigs.Add($IpConfig)
}

$NetworkInterface = New-AzNetworkInterface @CommonProps -IpConfiguration $IpConfigs

"Virtual Network: " + $VirtualNetwork.Name
"Subnet: " + $SubnetA.Name
"NIC: " + $NetworkInterface.Id

foreach ($IpConfig in $IpConfigs) {
    ">>>>>>> IpConfig Name: " + $IpConfig.Name
}