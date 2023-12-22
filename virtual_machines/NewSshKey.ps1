$ApplicationId = "qrpayments"
$Tags = @{
    Provisioner = "PowerShell"
    Environment = "Development"
    "Technical-Owner" = "TeamDragons"
    "Application-Id" = $ApplicationId
    "Data-Classification" = "Classified"
}

$ResourceGroupName = "TeamDragons_rg"
$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction Break

$SshKeyName =  $ApplicationId + "pk"

$SshKey = Get-AzSshKey -ResourceGroupName $ResourceGroupName -Name $SshKeyName -ErrorAction SilentlyContinue
if ($null -ne $SshKey) {
    "SSHKey Resource already exists: " + $SshKey.Name
    "SSHKey Resource ID: " + $SshKey.Id
    return
}

$PKContentPath = "ssh\vm-keys.pub" | Resolve-Path -Relative
$PKContent = Get-Content -Path $PKContentPath -ErrorAction SilentlyContinue
if ($null -eq $PKContent) {
    "No PK Content found in path: " + $PKContentPath
    return
}

"Creating new SSH Key Resource: " + $SshKeyName
$SshKey = New-AzSshKey -ResourceGroupName $ResourceGroup.ResourceGroupName -Name $SshKeyName -PublicKey $PKContent
New-AzTag -ResourceId $SshKey.Id -Tag $Tags
"SSH Key Resource created: " + $SshKey.Id
