$ResourceGroupName = "TeamDragons_rg"
$Location = "EastUS"
$Tag = @{
    Provisioner = "PowerShell"
    "Technical-Onwer" = "TeamDragons"
    "Application-Id" = "QR Payments"
    Environment = "Development"
}

$ResourceGroup = New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Tag $Tag
"Provioning State: " + $ResourceGroup.ProvisioningState
"Resource Group ID: " + $ResourceGroup.ResourceId