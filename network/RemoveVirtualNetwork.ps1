$ApplicationId = "qrpayments"

$ResourceGroupName = "TeamDragons_rg"
$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName
$VirtualNetworkName = "vnet" + $ApplicationId

Remove-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroup.ResourceGroupName -Force
"Virtual Network removed: " + $VirtualNetworkName