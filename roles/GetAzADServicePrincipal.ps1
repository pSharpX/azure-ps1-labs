Disable-AzContextAutosave
Connect-AzAccount

$ServicePrincipalName = "your_service_principal_display_name"
#$ApplicationId = "your_service_principal_app_id"

$ServicePrincipal = Get-AzADServicePrincipal -DisplayName $ServicePrincipalName
#$ServicePrincipal = Get-AzADServicePrincipal -ApplicationId $ApplicationId
$ServicePrincipal