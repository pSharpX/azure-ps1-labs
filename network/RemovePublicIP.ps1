$ApplicationId = "qrpayments"

$ResourceGroupName = "TeamDragons_rg"
$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName

$PublicIPName = "pip" + $ApplicationId
$PublicIPAddress = Get-AzPublicIpAddress -Name $PublicIPName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue

if ($null -ne $PublicIPAddress) {
    "Removing Public IP Adderess: $PublicIPName"
    Remove-AzPublicIpAddress -Name $PublicIPName -ResourceGroupName $ResourceGroup.ResourceGroupName -Force
    "Public IP removed successfully"
}
