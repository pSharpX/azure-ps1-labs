$ApplicationId = "qrpayments"

$ResourceGroupName = "TeamDragons_rg"
$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction Break

$NSGResourceType = "Microsoft.Network/networkSecurityGroups"
$NetworkScurityGroups = Get-AzResource -ResourceGroupName $ResourceGroupName -TagName "Application-Id" -TagValue $ApplicationId -ResourceType $NSGResourceType

if ($null -eq $NetworkScurityGroups){
    "No Network Security Group was found."
    return
}

$SecurityGroupName = $NetworkScurityGroups.Name
"Removing Network Security Group.."
Remove-AzNetworkSecurityGroup -Name $SecurityGroupName -ResourceGroupName $ResourceGroup.ResourceGroupName -Force
"Network Security Group removed: " + $SecurityGroupName

