$ResourceGroupName = "TeamPayments_rg"
$Location = "EastUS"
$Tag = @{
    "Provisioner" = "PowerShell"
    "Onwer" = "TeamPayments"
    "ApplicationId" = "QR Payments"
    "Environment" = "Development"
}

New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Tag $Tag