$Location = "East US"
Get-AzVMSize -Location $Location

$VMSizes = Get-AzVMSize -Location $Location
$VMSizes | Where-Object {$_.Name -eq "Standard_DS2_v2"}

$PublisherName = "canonical"
Get-AzVMImagePublisher -Location $Location | Where-Object {$_.PublisherName -eq $PublisherName}

Get-AzVMImageOffer -Location $Location -PublisherName $PublisherName

$Offer = "0001-com-ubuntu-server-jammy" #UbuntuServer
Get-AzVMImageSku -Location $Location -PublisherName $PublisherName -Offer $Offer

$Sku = "22_04-lts-gen2"
Get-AzVMImage -Location $Location -PublisherName $PublisherName -Offer $Offer -Skus $Sku