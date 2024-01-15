$ApplicationId = "qrpayments"

$ResourceGroupName = "TeamDragons_rg"
$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction Stop
$Location = $ResourceGroup.Location

# Azure resources to be created
$AppServicePlanName = $ApplicationId + "serviceplan"
$WebAppName = $ApplicationId + "webapp"

Write-Host "1. Get App Service Plan"
$AppServicePlan = Get-AzAppServicePlan -ResourceGroupName $ResourceGroupName -Name $AppServicePlanName -ErrorAction Stop
Write-Host "App Service Plan: $($AppServicePlan.Name)"

$CommonWebAppProps = @{
    ResourceGroupName = $ResourceGroup.ResourceGroupName
    Name = $WebAppName
    AppServicePlan = $AppServicePlan.Id
    ContainerImageName = "psharpx/productsmanagement-api:latest"
    #ContainerRegistryUrl = "your_container_registry"
    #ContainerRegistryUser = "your_container_registry_user"
    #ContainerRegistryPassword = "your_container_registry_password"
    #GitRepositoryPath = "your_github_repo_url"
    HttpLoggingEnabled = $true
    HttpsOnly = $true
}

Write-Host "2. Get or Create new Web App"
$WebApp = Get-AzWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName -ErrorAction Stop
Write-Host "Web App: $($WebApp.Name)"
Set-AzWebApp @CommonWebAppProps