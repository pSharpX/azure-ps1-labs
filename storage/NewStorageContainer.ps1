
$ResourceGroupName = "TeamDragons_rg"
$StorageAccountName = "qrpaymentsstorage" 
$ContainerName = "assets"

$StorageAccount = Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName
"Storage Account Id: " + $StorageAccount.Id

New-AzStorageContainer -Name $ContainerName -Context $StorageAccount.Context -Permission Off