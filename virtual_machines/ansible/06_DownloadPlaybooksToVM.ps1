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
$ContainerName = "playbooks"
$StorageContainer = Get-AzStorageContainer -Name $ContainerName -Context $StorageAccount.Context -ErrorAction Stop

Write-Host "Storage Container: $($StorageContainer.Name)"
$StorageBlobs = Get-AzStorageBlob -Container $StorageContainer.Name -Context $StorageAccount.Context -ErrorAction Stop
$StorageBlobs | ForEach-Object { Write-Host $_.ICloudBlob.Uri.AbsoluteUri }

Write-Host "1.2 Generate SAS Token"
$StartTime = Get-Date
$EndTime = $startTime.AddHours(2)
#New-AzStorageBlobSASToken -Container $StorageContainer.Name -Blob $BlobName -Permission r -StartTime $StartTime -ExpiryTime $EndTime -Protocol HttpsOnly
$ContainerSASToken = New-AzStorageContainerSASToken -Name $StorageContainer.Name -Context $StorageAccount.Context -Permission r -StartTime $StartTime -ExpiryTime $EndTime -Protocol HttpsOnly

Write-Host "2. Get Virtual Machine"
$VirtualMachine = Get-AzVM -Name $VirtualMachineName -ResourceGroupName $ResourceGroupName -ErrorAction Stop

Write-Host "2.2 Invoke RunCommand Resource for configuring Virtual Machine"
$Username = "crivera"
$Params = $StorageBlobs | ForEach-Object {"wget -O /home/$Username/ansible-playbooks/$($_.Name) '$($_.ICloudBlob.Uri.AbsoluteUri)$ContainerSASToken'"}
$ScriptString = 
@"
mkdir /home/$Username/ansible-playbooks`n$(-join$Params.ForEach{"$_`n"})
"@

$RunCommandName = $VirtualMachineName + "ansiblecommand"
$RunCommand = Get-AzVMRunCommand -ResourceGroupName $ResourceGroupName -RunCommandName $RunCommandName -VMName $VirtualMachineName -ErrorAction SilentlyContinue
if ($null -eq $RunCommand) {
    Write-Host "New RunCommand will be created"   
}
$CustomScriptProps = @{
    RunCommandName = $RunCommandName
    ResourceGroupName = $ResourceGroup.ResourceGroupName
    VMName = $VirtualMachine.Name
    SourceScript = $ScriptString
    Location = $Location
}
Write-Host "Running new Command: $($RunCommandName)"
Set-AzVMRunCommand @CustomScriptProps 

Write-Host "Execution completed"