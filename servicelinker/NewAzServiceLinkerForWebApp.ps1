$ApplicationId = "qrpayments"

$ResourceGroupName = "TeamDragons_rg"
$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction Stop

$SubscriptionName = "AS_BASIC"
$Subscription = Get-AzSubscription -SubscriptionName $SubscriptionName

# Azure resources to be used/created
$SqlServerName = $ApplicationId + "sqlserver"
$SqlDatabaseName = $ApplicationId + "database"
$WebAppName = $ApplicationId + "webapp"
$IdentityName = $ApplicationId + "identity"
$ServiceLinkerName = $ApplicationId + "servicelinker"

Write-Host "1. Get existent User-Assigned Identity (Managed Identity)"
$ManagedIdentity = Get-AzUserAssignedIdentity -ResourceGroupName $ResourceGroupName -Name $IdentityName -ErrorAction Stop

Write-Host "2. Get existent SQL Database"
$SqlDatabase = Get-AzSqlDatabase -ResourceGroupName $ResourceGroupName -ServerName $SqlServerName -DatabaseName $SqlDatabaseName -ErrorAction Stop

Write-Host "3. Get existent Web App"
$WebApp = Get-AzWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName -ErrorAction Stop

Write-Host "3. Get or Create Service Linker for WebApp"
$Target = New-AzServiceLinkerAzureResourceObject -Id $SqlDatabase.ResourceId
$AuthInfo = New-AzServiceLinkerUserAssignedIdentityAuthInfoObject -ClientId $ManagedIdentity.ClientId -SubscriptionId $Subscription.SubscriptionId

$CommonProps = @{
    TargetService = $Target
    AuthInfo = $AuthInfo
    ClientType = 'java' #dotnet, python, php, go, nodejs, ruby, springBoot, django
    LinkerName = $ServiceLinkerName
    WebApp = $WebApp.Name
    ResourceGroupName = $ResourceGroup.ResourceGroupName
}
$ServiceLinker = New-AzServiceLinkerForWebApp @CommonProps
Write-Host "Service Linker for Web App: $($ServiceLinker.Name)"