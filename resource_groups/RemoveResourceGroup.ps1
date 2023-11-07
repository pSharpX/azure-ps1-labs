$ResourceGroupName = "TeamDragons_rg"

Remove-AzResourceGroup -Name $ResourceGroupName -Force
"Resource Group removed: " + $ResourceGroupName