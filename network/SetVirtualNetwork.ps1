<#
The New-AzVirtualNetworkSubnetConfig template only creates an in-memory representation of the subnet.
The Add-AzVirtualNetworkSubnetConfig cmdlet adds a subnet configuration to an existing Azure virtual network.
The Set-AzVirtualNetworkSubnetConfig cmdlet updates a subnet configuration for a virtual network.
#>

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

$VirtualNetworkProps = @{
    Name = $VirtualNetworkName
    ResourceGroupName = $ResourceGroupName
    Location = $Location
    AddressPrefix = "10.0.0.0/16"
    Tag = $Tags
    ErrorAction = "Break"
}

$SubnetFrontEndProps = @{
    Name = "SubnetFrontEnd"
    AddressPrefix = "10.0.4.0/24"
}
$SubnetBackEndProps = @{
    Name = "SubnetBackEnd"
    AddressPrefix = "10.0.5.0/24"
}

$SubnetFrontEnd = New-AzVirtualNetworkSubnetConfig @SubnetFrontEndProps
$SubnetBackEnd = New-AzVirtualNetworkSubnetConfig @SubnetBackEndProps

$VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkProps.Name -ResourceGroupName $VirtualNetworkProps.ResourceGroupName -ErrorAction SilentlyContinue
if ($null -eq $VirtualNetwork) {
    $VirtualNetwork = New-AzVirtualNetwork @VirtualNetworkProps -Subnet $SubnetFrontEnd, $SubnetBackEnd
}
"Virtual Network ID: " + $VirtualNetwork.Id

$SubnetAProps = @{
    Name = "SubnetA"
    AddressPrefix = "10.0.1.0/24"
    VirtualNetwork = $VirtualNetwork
}
$SubnetBProps = @{
    Name = "SubnetB"
    AddressPrefix = "10.0.2.0/24"
    VirtualNetwork = $VirtualNetwork
}
$SubnetCProps = @{
    Name = "SubnetC"
    AddressPrefix = "10.0.3.0/24"
    VirtualNetwork = $VirtualNetwork
}

Add-AzVirtualNetworkSubnetConfig @SubnetAProps
Add-AzVirtualNetworkSubnetConfig @SubnetBProps
Add-AzVirtualNetworkSubnetConfig @SubnetCProps

$VirtualNetwork | Set-AzVirtualNetwork

foreach ($Subnet in $VirtualNetwork.Subnets) {
    "Subnet: " + $Subnet.Name
}