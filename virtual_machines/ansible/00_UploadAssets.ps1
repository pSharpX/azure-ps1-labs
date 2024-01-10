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
$StorageAccountName = $ApplicationId + "storage"

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
        ErrorAction = "Stop"
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
        ErrorAction = "Stop"
    }
    Write-Host "Creating new Storage Container ($($ContainerName)) ..."
    $StorageContainer = New-AzStorageContainer  @ContainerProps
}
Write-Host "Storage Container: $($StorageContainer.Name)"

$BlobName = "install_ansible.sh"
$StorageBlob = Get-AzStorageBlob -Container $StorageContainer.Name -Context $StorageAccount.Context -Blob $BlobName -ErrorAction SilentlyContinue
if ($null -eq $StorageBlob) {
    $StorageBlobContentProps = @{
        Container = $StorageContainer.Name
        Context = $StorageAccount.Context
        File = ".\config\linux\install_ansible.sh"
        Blob = $BlobName
        ErrorAction = "Stop"
    }
    Write-Host "Creating new Storage Blob ($($StorageBlobContentProps.Blob)) ..."
    Set-AzStorageBlobContent @StorageBlobContentProps
    $StorageBlob = Get-AzStorageBlob -Container $StorageContainer.Name -Context $StorageAccount.Context -Blob $StorageBlobContentProps.Blob
}
Write-Host "Storage Blob: $($StorageBlob.Name)"
$BlobUri = $StorageBlob.ICloudBlob.Uri.AbsoluteUri
$StorageAccountKeys = Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
$DefaultStorageAccountKey = $StorageAccountKeys | Where-Object {$_.KeyName -eq "key1"}

Write-Host "Blob URL: $BlobUri"
Write-Host "Storage Account Default Key: $DefaultStorageAccountKey"



