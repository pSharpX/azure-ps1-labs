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
$WebAppName = $ApplicationId + "webapp"

$CommonProps = @{
    ResourceGroupName = $ResourceGroup.ResourceGroupName
    Location = $Location
    Name = $AppServicePlanName
    Tier = "Standard" # Free, Basic, Standard, Premium
    NumberofWorkers = 2
    WorkerSize = "Small" # Small, Medium, Large
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


$CommonWebAppProps = @{
    ResourceGroupName = $ResourceGroup.ResourceGroupName
    Location = $Location
    Name = $WebAppName
    AppServicePlan = $AppServicePlan.Id
    ContainerImageName = "psharpx/productsmanagement-api:latest"
    #ContainerRegistryUrl = "your_container_registry"
    #ContainerRegistryUser = "your_container_registry_user"
    #ContainerRegistryPassword = "your_container_registry_password"
    #GitRepositoryPath = "your_github_repo_url"
    Tag = $Tags
}

Write-Host "2. Get or Create new Web App"
$WebApp = Get-AzWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName -ErrorAction SilentlyContinue
if ($null -eq $WebApp) {
    Write-Host "Creating new Web App.."
    $WebApp = New-AzWebApp @CommonWebAppProps
}
Write-Host "Web App: $($WebApp.Name)"
Write-Host "Web App Hostname: $($WebApp.DefaultHostName)"