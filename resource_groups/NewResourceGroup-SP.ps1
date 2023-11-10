$ResourceGroupName = "TeamDragons_rg"
$Location = "EastUS"
$Tag = @{
    Provisioner = "PowerShell"
    "Technical-Onwer" = "TeamDragons"
    "Application-Id" = "QR Payments"
    Environment = "Development"
}

$AppId = "your_app_id"
$AppSecret = "your_app_secret"

$SecureSecret = $AppSecret | ConvertTo-SecureString -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential `
-ArgumentList $AppId,$SecureSecret

$TenantId = "your_tenant_id"

Connect-AzAccount -ServicePrincipal -Credential $Credential -Tenant $TenantId
New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Tag $Tag