$ApplicationId = "qrpayments"

$ResourceGroupName = "TeamDragons_rg"
$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction Stop

# Azure resources to be created
$AppServicePlanName = $ApplicationId + "serviceplan"
$WebAppName = $ApplicationId + "webapp"

Write-Host "1. Get App Service Plan"
$AppServicePlan = Get-AzAppServicePlan -ResourceGroupName $ResourceGroupName -Name $AppServicePlanName -ErrorAction Stop
Write-Host "App Service Plan: $($AppServicePlan.Name)"

Write-Host "2. Get or Create new Web App"
$WebApp = Get-AzWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName -ErrorAction Stop

$AppSettings = @{}
foreach ($Item in $WebApp.SiteConfig.AppSettings) {
    $AppSettings[$Item.Name] = $Item.Value
}

# Configure Spring Boot application using environment variables
$AppSettings["SPRING_PROFILES_ACTIVE"] = "dev"
$AppSettings["SERVER_PORT"] = "80"
$AppSettings["DATABASE_HOSTNAME"] = "your_server_hostname"
$AppSettings["DATABASE_PORT"] = "port_number"
$AppSettings["DATABASE_NAME"] = "your_database_name"
$AppSettings["SPRING_DATASOURCE_USERNAME"] = "your_username"
$AppSettings["SPRING_DATASOURCE_PASSWORD"] = "your_password"
$AppSettings["SPRING_DATASOURCE_DRIVERCLASSNAME"] = "com.microsoft.sqlserver.jdbc.SQLServerDriver"
$AppSettings["SPRING_JPA_PROPERTIES_HIBERNATE_DIALECT"] = "org.hibernate.dialect.SQLServer2012Dialect"
$AppSettings["SPRING_DATASOURCE_URL"] = "your_database_url"

$ContainerImageName = "psharpx/productsmanagement-api:latest"

$CommonWebAppProps = @{
    ResourceGroupName = $ResourceGroup.ResourceGroupName
    Name = $WebAppName
    AppServicePlan = $AppServicePlan.Id
    ContainerImageName = $ContainerImageName
    #ContainerRegistryUrl = "your_container_registry"
    #ContainerRegistryUser = "your_container_registry_user"
    #ContainerRegistryPassword = "your_container_registry_password"
    #GitRepositoryPath = "your_github_repo_url"
    AppSettings = $AppSettings
    HttpLoggingEnabled = $true
    HttpsOnly = $true
}

Write-Host "Web App: $($WebApp.Name)"
Set-AzWebApp @CommonWebAppProps