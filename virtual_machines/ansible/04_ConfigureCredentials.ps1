$ApplicationId = "qrpayments"

$ResourceGroupName = "TeamDragons_rg"
$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction Stop

# Resources to Use/Create
$KeyVaultName = "kv" + $ApplicationId
$AppIdKeyName = "ansible-sp-appid"
$AppSecretKeyName = "ansible-sp-appsecret"
$VirtualMachineName = "ansiblevm" + $ApplicationId

Write-Host "1. Get Secrets from Key Vault"
Write-Host "Key Vault Resource: $($KeyVaultName)"
$AppIdSecret = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $AppIdKeyName -AsPlainText -ErrorAction Stop
$AppSecretSecret = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $AppSecretKeyName -AsPlainText -ErrorAction Stop
Write-Host "Secrets found: $($AppIdKeyName), $($AppSecretKeyName)"

Write-Host "2. Get Virtual Machine"
$VirtualMachine = Get-AzVM -Name $VirtualMachineName -ResourceGroupName $ResourceGroupName -ErrorAction Stop

Write-Host "2.2 Invoke RunCommand Resource for configuring Virtual Machine"
$SubscriptionId = "your_subscription_id"
$ApplicationId = $AppIdSecret
$ApplicationSecret = $AppSecretSecret
$TenantId = "your_tenant_id"
$Username = "crivera"
<#
$ScriptString = 
@"
export AZURE_SUBSCRIPTION_ID=$($SubscriptionId)
export AZURE_CLIENT_ID=$($ApplicationId)
export AZURE_SECRET=$($ApplicationSecret)
export AZURE_TENANT=$($TenantId)
"@
#>

##!/bin/bash
$ScriptString = 
@"
mkdir /home/$($Username)/.azure
touch /home/$($Username)/.azure/credentials
cat > /home/$($Username)/.azure/credentials <<EOL
[default]
subscription_id=$($SubscriptionId)
client_id=$($ApplicationId)
secret=$($ApplicationSecret)
tenant=$($TenantId)
EOL
"@


$RunCommandName = $VirtualMachineName + "command"
$RunCommand = Get-AzVMRunCommand -ResourceGroupName $ResourceGroupName -RunCommandName $RunCommandName -VMName $VirtualMachineName -ErrorAction SilentlyContinue
if ($null -eq $RunCommand) {
    $CustomScriptProps = @{
        ResourceGroupName = $ResourceGroup.ResourceGroupName
        VMName = $VirtualMachine.Name
        CommandId = "RunShellScript" #For Windows-> RunPowerShellScript
        ScriptString = $ScriptString
    }
    Write-Host "Running new Command: $($RunCommandName)"
    Invoke-AzVMRunCommand @CustomScriptProps
}

Write-Host "Execution completed"