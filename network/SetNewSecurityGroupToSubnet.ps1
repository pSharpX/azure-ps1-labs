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

$SecurityGroupName = "nsg" + $ApplicationId
$VirtualNetworkName = "vnet" + $ApplicationId
$SubnetName = "SubnetA"

$CommonProps = @{
    ResourceGroupName = $ResourceGroupName
    Location = $Location
    Tag = $Tags
}

$SecurityGroupRulesProps = @(
    @{
        Name = "http-rule"
        Description = "Allow HTTP All"
        Protocol = "Tcp"
        Access = "Allow"
        Direction = "Inbound"
        Priority = 100
        SourceAddressPrefix = "*"
        SourcePortRange = "*"
        DestinationAddressPrefix = "*"
        DestinationPortRange = 8080
    }
    @{
        Name = "https-rule"
        Description = "Allow HTTPS All"
        Protocol = "Tcp"
        Access = "Allow"
        Direction = "Inbound"
        Priority = 101
        SourceAddressPrefix = "*"
        SourcePortRange = "*"
        DestinationAddressPrefix = "*"
        DestinationPortRange = 443
    }
    @{
        Name = "ssh-rule"
        Description = "Allow SSH All"
        Protocol = "Tcp"
        Access = "Allow"
        Direction = "Inbound"
        Priority = 102
        SourceAddressPrefix = "*"
        SourcePortRange = "*"
        DestinationAddressPrefix = "*"
        DestinationPortRange = 22
    }
)

$VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName
$Subnet = $VirtualNetwork | Get-AzVirtualNetworkSubnetConfig -Name $SubnetName

$SecurityGroupRules = New-Object System.Collections.Generic.List[System.Object]
foreach ($SecurityGroupRuleProps in $SecurityGroupRulesProps) {
    $SecurityGroupRule = New-AzNetworkSecurityRuleConfig @SecurityGroupRuleProps
    $SecurityGroupRules.Add($SecurityGroupRule)
}

"Retrieving Network Security Groups: " + $SecurityGroupName
$NetworkSecurityGroup = Get-AzNetworkSecurityGroup -Name $SecurityGroupName -ResourceGroupName $ResourceGroupName
if ($null -eq $NetworkSecurityGroup) {
    "Network Security Groups was not found"
    "Creating new Network Security Groups: "
    $NetworkSecurityGroup = New-AzNetworkSecurityGroup @CommonProps -Name $SecurityGroupName -SecurityRules $SecurityGroupRules
}

"Assigning Network Security Group to existent Virtual Network Subnet: " + $Subnet.Name
$VirtualNetwork | Set-AzVirtualNetworkSubnetConfig -Name $Subnet.Name -NetworkSecurityGroup $NetworkSecurityGroup -AddressPrefix "10.0.1.0/24"

"Updating new Virtual Network Configuration.."
$VirtualNetwork | Set-AzVirtualNetwork