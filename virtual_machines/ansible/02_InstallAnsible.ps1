$ApplicationId = "qrpayments"

$ResourceGroupName = "TeamDragons_rg"
$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction Stop
$Location = $ResourceGroup.Location

# Resources to Use/Create
$StorageAccountName = $ApplicationId + "storage"
$VirtualMachineName = "ansiblevm" + $ApplicationId

Write-Host "1. Get Storage Account/Containers/Blobs"
$StorageAccount = Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName -ErrorAction Stop

Write-Host "Storage Account Id: $($StorageAccount.Id)"
$ContainerName = "assets"
$StorageContainer = Get-AzStorageContainer -Name $ContainerName -Context $StorageAccount.Context -ErrorAction Stop

Write-Host "Storage Container: $($StorageContainer.Name)"
$BlobName = "install_ansible.sh"
$StorageBlob = Get-AzStorageBlob -Container $StorageContainer.Name -Context $StorageAccount.Context -Blob $BlobName -ErrorAction Stop

Write-Host "Storage Blob: $($StorageBlob.Name)"
$BlobUri = $StorageBlob.ICloudBlob.Uri.AbsoluteUri
$StorageAccountKeys = Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
$DefaultStorageAccountKey = $StorageAccountKeys | Where-Object {$_.KeyName -eq "key1"}

Write-Host "4. Get Virtual Machine"
$VirtualMachine = Get-AzVM -Name $VirtualMachineName -ResourceGroupName $ResourceGroupName -ErrorAction Stop

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
        "commandToExecute" = "sh install_ansible.sh"
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
    Set-AzVMExtension -VMName $VirtualMachine.Name @CustomScriptProps
}

Write-Host "Execution completed"