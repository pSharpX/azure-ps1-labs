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

# Resources to Use/Create
$StorageAccountName = $ApplicationId + "storage"
$VirtualMachineName = "vm" + $ApplicationId
$NetworkInterfaceName = "nic" + $ApplicationId
$SshKeyName =  $VirtualMachineName + "key"

Write-Host "1. Get or Create Storage Account/Containers/Blobs"
$StorageAccount = Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
if ($null -eq $StorageAccount) {
    $StorageProps = @{
        Name = $ApplicationId + "storage"
        Location = $Location
        ResourceGroupName = $ResourceGroupName
        SkuName = "Standard_LRS"
        Kind = "StorageV2"
        AccessTier = "Hot"
        EnableHttpsTrafficOnly = $true
        AllowBlobPublicAccess = $false
        Tag = $Tags
        ErrorAction = "Break"
    }    
    Write-Host "Creating new Storage Account ($($StorageProps.Name)) ..."
    $StorageAccount = New-AzStorageAccount @StorageProps
}
Write-Host "Storage Account Id: $($StorageAccount.Id)"

$ContainerName = "assets"
$StorageContainer = Get-AzStorageContainer -Name $ContainerName -Context $StorageAccount.Context -ErrorAction SilentlyContinue
if ($null -eq $StorageContainer) {
    $ContainerProps = @{
        Name = $ContainerName
        Context = $StorageAccount.Context
        Permission = "Off"
        ErrorAction = "Break"
    }
    Write-Host "Creating new Storage Container ($($ContainerName)) ..."
    $StorageContainer = New-AzStorageContainer  @ContainerProps
}
Write-Host "Storage Container: $($StorageContainer.Name)"

$BlobName = "install_docker.sh"
$StorageBlob = Get-AzStorageBlob -Container $StorageContainer.Name -Context $StorageAccount.Context -Blob $BlobName -ErrorAction SilentlyContinue
if ($null -eq $StorageBlob) {
    $StorageBlobContentProps = @{
        Container = $StorageContainer.Name
        Context = $StorageAccount.Context
        File = ".\config\linux\install_docker.sh"
        Blob = $BlobName
        ErrorAction = "Break"
    }
    Write-Host "Creating new Storage Blob ($($StorageBlobContentProps.Blob)) ..."
    Set-AzStorageBlobContent @StorageBlobContentProps
    $StorageBlob = Get-AzStorageBlob -Container $StorageContainer.Name -Context $StorageAccount.Context -Blob $StorageBlobContentProps.Blob
}
Write-Host "Storage Blob: $($StorageBlob.Name)"
$BlobUri = $StorageBlob.ICloudBlob.Uri.AbsoluteUri
$StorageAccountKeys = Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
$DefaultStorageAccountKey = $StorageAccountKeys | Where-Object {$_.KeyName -eq "key1"}


Write-Host "2. Get Network Interface"
$NetworkInterface = Get-AzNetworkInterface -Name $NetworkInterfaceName -ResourceGroupName $ResourceGroupName -ErrorAction Break

Write-Host "3. Get or Create New SSH Key Resource"
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

Write-Host "4. Get or Create new Virtual Machine"
Write-Host "4.1 Configure and Get/Create new Virtual Machine"
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

Write-Host "4.2 Get or Create CustomScriptExtension Resource for Virtual Machine"
$CustomScriptName = $VirtualMachineName + "script"
$CustomScript = Get-AzVMExtension -ResourceGroupName $ResourceGroupName -Name $CustomScriptName -VMName $VirtualMachineName -ErrorAction SilentlyContinue
if ($null -eq $CustomScript) {
    $Settings = @{
        "fileUris" = @($BlobUri)
    }
    $ProtectedSettings = @{
        "storageAccountName" = $StorageAccountName
        "storageAccountKey" = $DefaultStorageAccountKey.Value
        "commandToExecute" = "sh install_docker.sh $($Username)"
    }
    $CustomScriptProps = @{
        Publisher = "Microsoft.Azure.Extensions"
        ExtensionType = "CustomScript"
        ResourceGroupName = $ResourceGroupName
        Name = $CustomScriptName
        Location = $Location
        TypeHandlerVersion = "2.1"
        Settings = $Settings
        ProtectedSettings = $ProtectedSettings
    }
    Write-Host "Creating new Custom Script Extension: $($CustomScriptName)"
    Set-AzVMExtension -VMName $VirtualMachineName @CustomScriptProps
}
