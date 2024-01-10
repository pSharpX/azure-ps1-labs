$ApplicationId = "qrpayments"
$Tags = @{
    Provisioner = "PowerShell"
    Environment = "Development"
    "Technical-Owner" = "TeamDragons"
    "Application-Id" = $ApplicationId
    "Data-Classification" = "Restricted"
}

$ResourceGroupName = "TeamDragons_rg"
$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction Stop
$Location = $ResourceGroup.Location

# Resources to Use/Create
$VirtualMachineName = "ansiblevm" + $ApplicationId
$NetworkInterfaceName = "nic" + $ApplicationId
$SshKeyName =  $VirtualMachineName + "key"

Write-Host "1. Get Network Interface"
$NetworkInterface = Get-AzNetworkInterface -Name $NetworkInterfaceName -ResourceGroupName $ResourceGroupName -ErrorAction Stop

Write-Host "2. Get or Create New SSH Key Resource"
$SshKey = Get-AzSshKey -ResourceGroupName $ResourceGroupName -Name $SshKeyName -ErrorAction SilentlyContinue
if ($null -eq $SshKey) {
    $PKContentPath = "ssh\vm-keys.pub" | Resolve-Path -Relative
    $PKContent = Get-Content -Path $PKContentPath -ErrorAction Break
    if ($null -eq $PKContent) {
        Write-Host "No PK Content found in path: $($PKContentPath)"
        return
    }

    "SSH Key Resource was not found: $($SshKeyName)"
    $SshKey = New-AzSshKey -ResourceGroupName $ResourceGroup.ResourceGroupName -Name $SshKeyName -PublicKey $PKContent
    New-AzTag -ResourceId $SshKey.Id -Tag $Tags
    "New SSH Key Resource was created"
}

Write-Host "3. Get or Create new Virtual Machine"
$VirtualMachine = Get-AzVM -Name $VirtualMachineName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
if ($null -eq $VirtualMachine) {
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
    Set-AzVMOperatingSystem -VM $VMConfig -Linux -ComputerName $ComputerName -Credential $Credentials -DisablePasswordAuthentication
    Set-AzVMBootDiagnostic -VM $VMConfig -Disable
    $VMConfig = Add-AzVMNetworkInterface -VM $VMConfig -NetworkInterface $NetworkInterface

    Write-Host "Creating new Virtual Machine: $($VirtualMachineName)"
    $VirtualMachine = New-AzVM -VM $VMConfig -ResourceGroupName $ResourceGroupName -Location $Location -Tag $Tags -SshKeyName $SshKey.Name -ErrorAction Break
    Write-Host "Virtual Machine Name: $($VirtualMachineName)"
}