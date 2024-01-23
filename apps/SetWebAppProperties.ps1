$ApplicationId = "qrpayments"

$ResourceGroupName = "TeamDragons_rg"
$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction Stop

# Azure resources to be created
$AppServicePlanName = $ApplicationId + "serviceplan"
$WebAppName = $ApplicationId + "webapp"

Write-Host "1. Get App Service Plan"
$AppServicePlan = Get-AzAppServicePlan -ResourceGroupName $ResourceGroupName -Name $AppServicePlanName -ErrorAction Stop
Write-Host "App Service Plan: $($AppServicePlan.Name)"

Write-Host "2. Update existent Web App"
$WebApp = Get-AzWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName -ErrorAction Stop

#$ContainerImageName = "psharpx/productsmanagement:latest"
$PropertiesObject = @{
    #LinuxFxVersion = "DOCKER|$ContainerImageName"
    HealthCheckPath = "/products-management/actuator/health"
    HttpLoggingEnabled = $true
    HttpsOnly = $true
}

<#
Properties in WebApp to update using Set-AzResource
1. LinuxFxVersion => DOCKER|psharpx/productsmanagement:latest
2. AppSettings => HashTable @{}
3. HealthCheckPath
#>

Set-AzResource -Properties $PropertiesObject -ResourceGroupName $ResourceGroup.ResourceGroupName -ResourceType Microsoft.Web/sites/config -ResourceName "$($WebApp.Name)/web" -ApiVersion 2018-02-01 -Force
