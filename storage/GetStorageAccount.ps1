
$ResourceGroupName = "TeamDragons_rg"
$StorageAccountName = "qrpaymentsstorage" 

$StorageAccount = Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName
"Storage Account Id: " + $StorageAccount.Id