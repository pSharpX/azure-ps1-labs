$ApplicationId = "qrpayments"

$ResourceGroupName = "TeamDragons_rg"
$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction Break

$SshKeyName =  $ApplicationId + "pk"

$SshKey = Get-AzSshKey -ResourceGroupName $ResourceGroupName -Name $SshKeyName -ErrorAction SilentlyContinue
if ($null -eq $SshKey) {
    "SSHKey Resource not found: " + $SshKey.Name
    return
}


"Removing SSH Key Resource: " + $SshKeyName
Remove-AzSshKey -ResourceGroupName $ResourceGroup.ResourceGroupName -Name $SshKeyName
"Operation finished successfully"
