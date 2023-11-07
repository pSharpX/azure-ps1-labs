$ResourceGroupName = "TeamDragons_rg"

$ExistentResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName
"Provioning State: " + $ExistentResourceGroup.ProvisioningState
"Resource Group ID: " + $ExistentResourceGroup.ResourceId

"=========================================================="

$ExistentResourceGroups = Get-AzResourceGroup
foreach($Group in $ExistentResourceGroups)
{
    "Provioning State: " + $Group.ProvisioningState
    "Resource Group ID: " + $Group.ResourceId
    "Resource Group Name: " + $Group.ResourceGroupName
}