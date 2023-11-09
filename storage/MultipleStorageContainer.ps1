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
    "Creating new Storage Account (" + $StorageProps.Name + ") ..."
    $StorageAccount = New-AzStorageAccount @StorageProps
}
"Storage Account Id: " + $StorageAccount.Id

$Containers = @(
    @{
        Name = "containera"
        Context = $StorageAccount.Context
        Permission = "Off"
        ErrorAction = "Break"
    }
    @{
        Name = "containerb"
        Context = $StorageAccount.Context
        Permission = "Off"
        ErrorAction = "Break"
    }
    @{
        Name = "containerc"
        Context = $StorageAccount.Context
        Permission = "Off"
        ErrorAction = "Break"
    }
)

foreach ($ContainerProps in $Containers) {
    $StorageContainer = Get-AzStorageContainer -Name $ContainerProps.Name -Context $ContainerProps.Context -ErrorAction SilentlyContinue
    if ($null -eq $StorageContainer) {
        "Creating new Storage Container (" + $ContainerProps.Name + ") ..."
        $StorageContainer = New-AzStorageContainer  @ContainerProps
    }
    "Storage Container: " + $StorageContainer.Name
}
