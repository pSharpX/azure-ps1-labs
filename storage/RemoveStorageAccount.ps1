
$ResourceGroupName = "TeamDragons_rg"
$StorageAccountName = "qrpaymentsstorage" 

$StorageAccount = Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName
"Storage Account Id: " + $StorageAccount.Id

Remove-AzStorageAccount -Name $StorageAccount.StorageAccountName -ResourceGroupName $StorageAccount.ResourceGroupName
"Storage Account removed: " + $StorageAccount.StorageAccountName