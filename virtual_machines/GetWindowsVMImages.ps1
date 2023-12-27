$Location = "East US"
Get-AzVMSize -Location $Location

$VMSizes = Get-AzVMSize -Location $Location
$VMSizes | Where-Object {$_.Name -eq "Standard_DS2_v2"}

<# Some Windows Image Publishers:
MicrosoftWindowsDesktop
MicrosoftWindowsServer
#>
$PublisherName = "MicrosoftWindowsDesktop" 
Get-AzVMImagePublisher -Location $Location | Where-Object {$_.PublisherName -eq $PublisherName}
#Get-AzVMImagePublisher -Location $Location | Where-Object {$_.PublisherName -like "*$PublisherName*"}

<# Some Offers for "MicrosoftWindowsDesktop" Publisher:
office-365
Windows-10
windows-10-20h2-vhd-client-prod-stage
windows-11
windows-7
windows-ent-cpc
windows10preview
windows11preview
windows11preview-arm64

Some Offers for "MicrosoftWindowsServer" Publisher:
servertesting
windows-cvm
WindowsServer
windowsserver-gen2preview
windowsserver-previewtest
windowsserverdotnet
windowsserverhotpatch-previews
WindowsServerSemiAnnual
windowsserverupgrade
#>
Get-AzVMImageOffer -Location $Location -PublisherName $PublisherName | Select-Object -Property Offer

$Offer = "windows-11" #"WindowsServer"
Get-AzVMImageSku -Location $Location -PublisherName $PublisherName -Offer $Offer

$Sku = "win11-23h2-pro" #"2019-DataCenter"
Get-AzVMImage -Location $Location -PublisherName $PublisherName -Offer $Offer -Skus $Sku