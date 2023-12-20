$Location = "East US"
Get-AzVMSize -Location $Location

$VMSizes = Get-AzVMSize -Location $Location
$VMSizes | Where-Object {$_.Name -eq "Standard_DS2_v2"}

$PublisherName = "MicrosoftWindowsServer"
Get-AzVMImagePublisher -Location $Location | Where-Object {$_.PublisherName -eq $PublisherName}

Get-AzVMImageOffer -Location $Location -PublisherName $PublisherName

$Offer = "WindowsServer"
Get-AzVMImageSku -Location $Location -PublisherName $PublisherName -Offer $Offer

$Sku = "2019-DataCenter"
Get-AzVMImage -Location $Location -PublisherName $PublisherName -Offer $Offer -Skus $Sku