$ApplicationId = "qrpayments"

$ResourceGroupName = "TeamDragons_rg"
$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName

$VirtualMachineName = "vm" + $ApplicationId

Remove-AzVM -Name $VirtualMachineName -ResourceGroupName $ResourceGroup.ResourceGroupName -Force
"Virtual Machine Removed: "+ $VirtualMachineName