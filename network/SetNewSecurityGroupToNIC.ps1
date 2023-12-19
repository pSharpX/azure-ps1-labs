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
$NetworkInterfaceName = "nic" + $ApplicationId

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

"Retrieving Network Security Groups: " + $SecurityGroupName
$NetworkSecurityGroup = Get-AzNetworkSecurityGroup -Name $SecurityGroupName -ResourceGroupName $ResourceGroupName
if ($null -eq $NetworkSecurityGroup) {
    "Network Security Groups was not found"

    $SecurityGroupRules = New-Object System.Collections.Generic.List[System.Object]
    foreach ($SecurityGroupRuleProps in $SecurityGroupRulesProps) {
        $SecurityGroupRule = New-AzNetworkSecurityRuleConfig @SecurityGroupRuleProps
        $SecurityGroupRules.Add($SecurityGroupRule)
    }

    "Creating new Network Security Groups: "
    $NetworkSecurityGroup = New-AzNetworkSecurityGroup @CommonProps -Name $SecurityGroupName -SecurityRules $SecurityGroupRules
}

"Retrieving Network Interface: " + $NetworkInterfaceName
$NetworkInterface = Get-AzNetworkInterface -Name $NetworkInterfaceName -ResourceGroupName $ResourceGroupName
$NetworkInterface.NetworkSecurityGroup = $NetworkSecurityGroup

$NetworkInterface | Set-AzNetworkInterface