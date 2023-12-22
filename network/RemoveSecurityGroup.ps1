$ApplicationId = "qrpayments"

$ResourceGroupName = "TeamDragons_rg"
$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName

$SecurityGroupName = "nsg" + $ApplicationId

$SecurityGroup = Get-AzNetworkSecurityGroup -Name $SecurityGroupName -ResourceGroupName $ResourceGroupName
if ($null -ne $SecurityGroup) {
    "Removing Network Security Group.."
    Remove-AzNetworkSecurityGroup -Name $SecurityGroupName -ResourceGroupName $ResourceGroup.ResourceGroupName -Force
    "Network Security Group removed: " + $SecurityGroupName
}

