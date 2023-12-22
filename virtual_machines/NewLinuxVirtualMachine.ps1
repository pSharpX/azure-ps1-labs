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

$VirtualMachineName = "vm" + $ApplicationId
$SshKeyName =  $VirtualMachineName + "key"
$NetworkInterfaceName = "nic" + $ApplicationId

$VMSize = "Standard_DS2_v2"
$PublisherName = "Canonical"
$Offer = "0001-com-ubuntu-server-jammy"
$Sku = "22_04-lts-gen2"

$NetworkInterface = Get-AzNetworkInterface -Name $NetworkInterfaceName -ResourceGroupName $ResourceGroupName

$ComputerName = "PC01" + $ApplicationId
$Username = "crivera"
$SecurePassword = '$L0y4lt1' | ConvertTo-SecureString -AsPlainText -Force
$Credentials = New-Object System.Management.Automation.PSCredential ($Username, $SecurePassword)

$VMConfig = New-AzVMConfig -VMName $VirtualMachineName -VMSize $VMSize -SecurityType Standard -Tags $Tags
$VMConfig = Set-AzVMSourceImage -VM $VMConfig -PublisherName $PublisherName -Offer $Offer -Skus $Sku -Version "latest"
$VMConfig = Set-AzVMOperatingSystem -VM $VMConfig -Linux -ComputerName $ComputerName -Credential $Credentials -DisablePasswordAuthentication
$VMConfig = Add-AzVMNetworkInterface -VM $VMConfig -NetworkInterface $NetworkInterface
#$VMConfig = Set-AzVMOSDisk -VM $VMConfig


$PKContentPath = "ssh\vm-keys.pub" | Resolve-Path -Relative
$PKContent = Get-Content -Path $PKContentPath -ErrorAction SilentlyContinue
if ($null -eq $PKContent) {
    "No PK Content found in path: " + $PKContentPath
    return
}
$SshKey = New-AzSshKey -ResourceGroupName $ResourceGroup.ResourceGroupName -Name $SshKeyName -PublicKey $PKContent
New-AzTag -ResourceId $SshKey.Id -Tag $Tags

$VirtualMachine = Get-AzVM -Name $VirtualMachineName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
if ($null -eq $VirtualMachine) {
    "Creating new Virtual Machine: " + $VirtualMachineName
    $VirtualMachine = New-AzVM -VM $VMConfig -ResourceGroupName $ResourceGroupName -Location $Location -Tag $Tags -SshKeyName $SshKey.Name
    "Virtual Machine Name: " + $VirtualMachineName
}
