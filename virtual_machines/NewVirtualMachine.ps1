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
$NetworkInterfaceName = "nic" + $ApplicationId

Get-AzVMSize -Location $Location
$VMSize = "Standard_DS2_v2"
$PublisherName = "MicrosoftWindowsServer"
Get-AzVMImagePublisher -Location $Location | Where-Object {$_.PublisherName -eq $PublisherName}
Get-AzVMImageOffer -Location $Location -PublisherName $PublisherName
$Offer = "WindowsServer" #UbuntuServer
Get-AzVMImageSku -Location $Location -PublisherName $PublisherName -Offer $Offer
$Sku = "2019-DataCenter"
Get-AzVMImage -Location $Location -PublisherName $PublisherName -Offer $Offer -Skus $Sku

$NetworkInterface = Get-AzNetworkInterface -Name $NetworkInterfaceName -ResourceGroupName $ResourceGroupName

$ComputerName = "PC01" + $ApplicationId
$Username = "crivera"
$SecurePassword = '$L0y4lt1' | ConvertTo-SecureString -AsPlainText -Force
$Credentials = New-Object System.Management.Automation.PSCredential ($Username, $SecurePassword)

$VMConfig = New-AzVMConfig -VMName $VirtualMachineName -VMSize $VMSize -SecurityType Standard -Tags $Tags

$VMConfig = Set-AzVMSourceImage -VM $VMConfig -PublisherName $PublisherName -Offer $Offer -Skus $Sku -Version "latest"
$VMConfig = Set-AzVMOperatingSystem -VM $VMConfig -Windows -ComputerName $ComputerName -Credential $Credentials
$VMConfig = Add-AzVMNetworkInterface -VM $VMConfig -NetworkInterface $NetworkInterface

$VirtualMachine = Get-AzVM -Name $VirtualMachineName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
if ($null -eq $VirtualMachine) {
    "Creating new Virtual Machine: " + $VirtualMachineName
    $VirtualMachine = New-AzVM -VM $VMConfig -ResourceGroupName $ResourceGroupName -Location $Location -Tag $Tags
    "Virtual Machine ID: "+ $VirtualMachine.Id
}
