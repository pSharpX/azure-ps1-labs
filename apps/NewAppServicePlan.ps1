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

# Azure resources to be created
$AppServicePlanName = $ApplicationId + "serviceplan"

$CommonProps = @{
    ResourceGroupName = $ResourceGroup.ResourceGroupName
    Location = $Location
    Name = $AppServicePlanName
    Tier = "Standard" # Free, Basic, Standard, Premium
    NumberofWorkers = 2
    WorkerSize = "Medium" # Small, Medium, Large
    Linux = $true
    Tag = $Tags
}

Write-Host "1. Get or Create new App Service Plan"
$AppServicePlan = Get-AzAppServicePlan -ResourceGroupName $ResourceGroupName -Name $AppServicePlanName -ErrorAction SilentlyContinue
if ($null -eq $AppServicePlan) {
    Write-Host "Creating new App Service Plan.."
    $AppServicePlan = New-AzAppServicePlan @CommonProps
}

Write-Host "App Service Plan: $($AppServicePlan.Name)"
