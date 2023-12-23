$ApplicationId = "qrpayments"
$Tags = @{
    Provisioner = "PowerShell"
    Environment = "Development"
    "Technical-Owner" = "TeamDragons"
    "Application-Id" = $ApplicationId
    "Data-Classification" = "Restricted"
}

$ResourceGroupName = "TeamDragons_rg"
$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction Break
$Location = $ResourceGroup.Location
$VirtualMachineName = "vm" + $ApplicationId

# Get Existent Network Interface
$NetworkInterfaceName = "nic" + $ApplicationId
$NetworkInterface = Get-AzNetworkInterface -Name $NetworkInterfaceName -ResourceGroupName $ResourceGroupName -ErrorAction Break

# Create New SSH Key Resource
$SshKeyName =  $VirtualMachineName + "key"

$PKContentPath = "ssh\vm-keys.pub" | Resolve-Path -Relative
$PKContent = Get-Content -Path $PKContentPath -ErrorAction Break
if ($null -eq $PKContent) {
    "No PK Content found in path: " + $PKContentPath
    return
}

$SshKey = Get-AzSshKey -ResourceGroupName $ResourceGroupName -Name $SshKeyName -ErrorAction SilentlyContinue
if ($null -eq $SshKey) {
    "SSH Key Resource was not found: $($SshKeyName)"
    $SshKey = New-AzSshKey -ResourceGroupName $ResourceGroup.ResourceGroupName -Name $SshKeyName -PublicKey $PKContent
    New-AzTag -ResourceId $SshKey.Id -Tag $Tags
    "New SSH Key Resource was created"
}

# Check if Virtual Machine already exist. Otherwise create a new one.
$VirtualMachine = Get-AzVM -Name $VirtualMachineName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
if ($null -ne $VirtualMachine) {
    "Virtual Machine already exist: $($VirtualMachineName)"
    return
}

# Retrieve CustomData Script for VM Provisioning
$CustomDataPath = ".\config\linux\cloud-init.yaml" | Resolve-Path -Relative
$CustomDataContent = Get-Content -Path $CustomDataPath -Raw -ErrorAction Break

# Configure and Create new Virtual Machine
$VMSize = "Standard_DS2_v2"
$OSCommonProps = @{
    PublisherName = "Canonical"
    Offer = "0001-com-ubuntu-server-jammy"
    Skus = "22_04-lts-gen2"
    Version = "latest"
}

$ComputerName = "PC01" + $ApplicationId
$Username = "crivera"
$SecurePassword = ' ' | ConvertTo-SecureString -AsPlainText -Force
$Credentials = New-Object System.Management.Automation.PSCredential ($Username, $SecurePassword)

$VMConfig = New-AzVMConfig -VMName $VirtualMachineName -VMSize $VMSize -SecurityType Standard -Tags $Tags
Set-AzVMSourceImage -VM $VMConfig @OSCommonProps
Set-AzVMOperatingSystem -VM $VMConfig -Linux -ComputerName $ComputerName -Credential $Credentials -DisablePasswordAuthentication -CustomData $CustomDataContent
Set-AzVMBootDiagnostic -VM $VMConfig -Disable
$VMConfig = Add-AzVMNetworkInterface -VM $VMConfig -NetworkInterface $NetworkInterface

"Creating new Virtual Machine: " + $VirtualMachineName
$VirtualMachine = New-AzVM -VM $VMConfig -ResourceGroupName $ResourceGroupName -Location $Location -Tag $Tags -SshKeyName $SshKey.Name
"Virtual Machine Name: " + $VirtualMachineName