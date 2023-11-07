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
$StorageAccountName = $ApplicationId + "storage" 
$SkuName = "Standard_LRS"
$Kind = "StorageV2"
$AccessTier = "Hot"
$EnableHttpsTrafficOnly = $true

New-AzStorageAccount -Name $StorageAccountName -Location $Location -ResourceGroupName $ResourceGroupName `
-SkuName $SkuName -Kind $Kind -AccessTier $AccessTier -EnableHttpsTrafficOnly $EnableHttpsTrafficOnly `
-Tag $Tags