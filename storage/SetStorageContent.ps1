
$ResourceGroupName = "TeamDragons_rg"
$StorageAccountName = "qrpaymentsstorage" 
$ContainerName = "assets"

$StorageAccount = Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName
"Storage Account Id: " + $StorageAccount.Id

Get-AzStorageContainer -Name $ContainerName -Context $StorageAccount.Context

Set-AzStorageBlobContent -Container $ContainerName -Context $StorageAccount.Context -File ".\storage\assets\message.txt" -Blob "message.txt"