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

$StorageProps = @{
    Name = $ApplicationId + "storage"
    Location = $Location
    ResourceGroupName = $ResourceGroupName
    SkuName = "Standard_LRS"
    Kind = "StorageV2"
    AccessTier = "Hot"
    EnableHttpsTrafficOnly = $true
    Tag = $Tags
    ErrorAction = "Break"
}
$StorageAccount = Get-AzStorageAccount -Name $StorageProps.Name -ResourceGroupName $StorageProps.ResourceGroupName -ErrorAction SilentlyContinue
if ($null -eq $StorageAccount) {
    <# Action to perform if the condition is true #>
    "Creating new Storage Account (" + $StorageProps.Name + ") ..."
    $StorageAccount = New-AzStorageAccount @StorageProps
}
"Storage Account Id: " + $StorageAccount.Id

$ContainerProps = @{
    Name = "assets"
    Context = $StorageAccount.Context
    Permission = "Off"
    ErrorAction = "Break"
}

$StorageContainer = Get-AzStorageContainer -Name $ContainerProps.Name -Context $ContainerProps.Context -ErrorAction SilentlyContinue
if ($null -eq $StorageContainer) {
    "Creating new Storage Container (" + $ContainerProps.Name + ") ..."
    $StorageContainer = New-AzStorageContainer  @ContainerProps
}
"Storage Container: " + $StorageContainer.Name

$StorageBlobContentProps = @{
    Container = $StorageContainer.Name
    Context = $StorageAccount.Context
    File = ".\storage\assets\message.txt"
    Blob = "message.txt"
    ErrorAction = "Break"
}
$StorageBlob = Get-AzStorageBlob -Container $StorageBlobContentProps.Container -Context $StorageBlobContentProps.Context -Blob $StorageBlobContentProps.Blob -ErrorAction SilentlyContinue
if ($null -eq $StorageBlob) {
    <# Action to perform if the condition is true #>
    "Creating new Storage Blob (" + $StorageBlobContentProps.Blob + ") ..."
    Set-AzStorageBlobContent @StorageBlobContentProps
    $StorageBlob = Get-AzStorageBlob -Container $StorageBlobContentProps.Container -Context $StorageBlobContentProps.Context -Blob $StorageBlobContentProps.Blob
}
"Storage Blob: " + $StorageBlob.Name