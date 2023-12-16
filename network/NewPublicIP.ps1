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

$PublicIPName = "pip" + $ApplicationId
$CommonProps = @{
    ResourceGroupName = $ResourceGroupName
    Location = $Location
    Tag = $Tags
}

$PublicIPAddress = New-AzPublicIpAddress @CommonProps -Name $PublicIPName -Sku "Standard" -AllocationMethod "Static"

"Public IP ID: " + $PublicIPAddress.Id