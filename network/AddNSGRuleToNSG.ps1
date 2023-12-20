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

$CommonProps = @{
    ResourceGroupName = $ResourceGroupName
    Location = $Location
    Tag = $Tags
}

$SecurityGroupRulesProps = @(
    @{
        Name = "rdp-rule"
        Description = "Allow RDP All"
        Protocol = "Tcp"
        Access = "Allow"
        Direction = "Inbound"
        Priority = 105
        SourceAddressPrefix = "*"
        SourcePortRange = "*"
        DestinationAddressPrefix = "*"
        DestinationPortRange = 3389
    }
)

"Retrieving Network Security Groups: " + $SecurityGroupName
$NetworkSecurityGroup = Get-AzNetworkSecurityGroup -Name $SecurityGroupName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
$SecurityGroupRules = New-Object System.Collections.Generic.List[System.Object]

if ($null -eq $NetworkSecurityGroup) {
    "Network Security Groups was not found"
    foreach ($SecurityGroupRuleProps in $SecurityGroupRulesProps) {
        $SecurityGroupRule = New-AzNetworkSecurityRuleConfig @SecurityGroupRuleProps
        $SecurityGroupRules.Add($SecurityGroupRule)
    }

    "Creating new Network Security Groups: "
    $NetworkSecurityGroup = New-AzNetworkSecurityGroup @CommonProps -Name $SecurityGroupName -SecurityRules $SecurityGroupRules

    return
}

$DefaultRuleConfig = "http-rule"
$NSGRuleConfigs = Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $NetworkSecurityGroup
$NSGRuleConfig = $NSGRuleConfigs | Where-Object {$_.Name -eq $DefaultRuleConfig}
"NSG Rule Config found: " +  $(If ($null -eq $NSGRuleConfig) {"NOTFOUND"} Else {$NSGRuleConfig.Name})

foreach ($SecurityGroupRuleProps in $SecurityGroupRulesProps) {
    if ($NSGRuleConfigs.Name -contains $SecurityGroupRuleProps.Name) {
        "Rule Config was found: " + $SecurityGroupRuleProps.Name + ". Skipping"    
    } else {
        $SecurityGroupRules.Add($SecurityGroupRuleProps)
    }
}

if ($SecurityGroupRules.Count -gt 0) {
    "Adding new Rule Configs for Network Security Group"
    foreach ($SecurityGroupRule in $SecurityGroupRules) {
        $NetworkSecurityGroup | Add-AzNetworkSecurityRuleConfig @SecurityGroupRule
    }
    $NetworkSecurityGroup | Set-AzNetworkSecurityGroup
    "Network Security Group updated: " + $NetworkSecurityGroup.Name
}

"Operation has finished"