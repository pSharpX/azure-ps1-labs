$ApplicationId = "qrpayments"
$Tags = @{
    Provisioner = "PowerShell"
    Environment = "Development"
    "Technical-Owner" = "TeamDragons"
    "Application-Id" = $ApplicationId
    "Data-Classification" = "Restricted"
}

$ResourceGroupName = "TeamDragons_rg"
$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction Break
$Location = $ResourceGroup.Location
$VirtualNetworkName = "vnet" + $ApplicationId
$SubnetName = "SubnetA"

$CommonProps = @{
    ResourceGroup = $ResourceGroupName
    Location = $Location
    Tags = $Tags
    ApplicationId = $ApplicationId
}

$VMCount = 2
$SshKey = GetOrCreate_SSHKey @CommonProps
$PublicIps = GetOrCreate_PublicIP  @CommonProps -Count $VMCount
$NetworkInterfaces = GetOrCreate_NetworkInterface @CommonProps -VirtualNetworkName $VirtualNetworkName -SubnetName $SubnetName -Count $VMCount
Set_PublicIpToNetworkInterface -NetworkInterfaces $NetworkInterfaces -PublicIps $PublicIps
$VirtualMachines = GetOrCreate_VirtualMachine @CommonProps -NetworkInterfaces $NetworkInterfaces -SshKeyName $SshKey.Name -Count $VMCount

function GetOrCreate_PublicIP {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroup,
        [Parameter(Mandatory=$true)]
        [hashtable]$Tags,
        [Parameter(Mandatory=$true)]
        [string]$Location,
        [Parameter(Mandatory=$true)]
        [string]$ApplicationId,
        [Parameter(Mandatory=$true)]
        [int]$Count
    )

    Write-Host "Get or Create Public IP Addresses"
    $PublicIpPrefix = "pip" + $ApplicationId
    $PublicIps = @()
    for ($i = 1; $i -le $Count; $i++) {
        $PublicIpName = $PublicIpPrefix + $i
        $PublicIp = Get-AzPublicIpAddress -Name $PublicIpName -ResourceGroupName $ResourceGroup -ErrorAction SilentlyContinue

        if ($null -eq $PublicIp) {
            $CommonProps = @{
                ResourceGroupName = $ResourceGroup
                Location = $Location
                Tag = $Tags
            }
            Write-Host "Creting new Public IP: $($PublicIpName)"
            $PublicIP = New-AzPublicIpAddress @CommonProps -Name $PublicIpName -Sku "Standard" -AllocationMethod "Static"
        }
        Write-Host "Public IP: $($PublicIp.Name)"
        $PublicIps += $PublicIp
    }
    return $PublicIps
}


function GetOrCreate_NetworkInterface {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroup,
        [Parameter(Mandatory=$true)]
        [string]$VirtualNetworkName,
        [Parameter(Mandatory=$true)]
        [string]$SubnetName,
        [Parameter(Mandatory=$true)]
        [hashtable]$Tags,
        [Parameter(Mandatory=$true)]
        [string]$Location,
        [Parameter(Mandatory=$true)]
        [string]$ApplicationId,
        [Parameter(Mandatory=$true)]
        [int]$Count
    )

    $VirtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName -ErrorAction Break
    $DefaultSubnet = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VirtualNetwork -ErrorAction Break

    Write-Host "Get or Create Network Interfaces"
    $NetworkInterfacePrefix = "nic" + $ApplicationId
    $NetworkInterfaces = @()
    for ($i = 1; $i -le $Count; $i++) {
        $NetworkInterfaceName = $NetworkInterfacePrefix + $i
        $NetworkInterface = Get-AzNetworkInterface -Name $NetworkInterfaceName -ResourceGroupName $ResourceGroup -ErrorAction SilentlyContinue

        if ($null -eq $NetworkInterface) {
            $CommonProps = @{
                Name = $NetworkInterfaceName
                ResourceGroupName = $ResourceGroup
                Location = $Location
                Tag = $Tags
            }
            $IpConfigProps = @{
                Name = "ipconfig1"
                PrivateIpAddressVersion = "IPv4"
                Primary = $True
            }
            $IpConfig = New-AzNetworkInterfaceIpConfig @IpConfigProps -Subnet $DefaultSubnet
            Write-Host "Creting new Network Interface: $($NetworkInterfaceName)"
            $NetworkInterface = New-AzNetworkInterface @CommonProps -IpConfiguration $IpConfig
        }

        Write-Host "Network Interface: $($NetworkInterface.Name)"
        $NetworkInterfaces += $NetworkInterface
    }
    return $NetworkInterfaces
}

function Set_PublicIpToNetworkInterface {
    param (
        [Parameter(Mandatory=$true)]
        [array]$NetworkInterfaces,
        [Parameter(Mandatory=$true)]
        [array]$PublicIps
    )

    foreach ($i in 0..($NetworkInterfaces.Length - 1)) {
        $NetworkInterface = $NetworkInterfaces[$i]
        $PublicIPAddress = $PublicIps[$i]

        $NetworkInterfaceIpConfigs = Get-AzNetworkInterfaceIpConfig -NetworkInterface $NetworkInterface
        $NetworkInterfacePrimaryIpConfig = $NetworkInterfaceIpConfigs | Where-Object Primary -eq $true

        Write-Host "Set Public IP Address ($($PublicIPAddress.Name)) to Network Interface ($($NetworkInterface.Name)/$($NetworkInterfacePrimaryIpConfig.Name))"
        Set-AzNetworkInterfaceIpConfig -NetworkInterface $NetworkInterface -Name $NetworkInterfacePrimaryIpConfig.Name -PublicIpAddress $PublicIPAddress
        Write-Host "Update Network Interface: $($NetworkInterface.Name)"
        Set-AzNetworkInterface -NetworkInterface $NetworkInterface
    }
}

function GetOrCreate_SSHKey {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroup,
        [Parameter(Mandatory=$true)]
        [hashtable]$Tags,
        [Parameter(Mandatory=$true)]
        [string]$Location,
        [Parameter(Mandatory=$true)]
        [string]$ApplicationId
    )

    Write-Host "Get or Create SSH Key Resource"
    $SshKeyName =  $ApplicationId + "key"
    $PKContentPath = "ssh\vm-keys.pub" | Resolve-Path -Relative
    $PKContent = Get-Content -Path $PKContentPath -ErrorAction Break

    $SshKey = Get-AzSshKey -ResourceGroupName $ResourceGroup -Name $SshKeyName -ErrorAction SilentlyContinue
    if ($null -eq $SshKey) {
        Write-Host "Creating new SSH Key Resource: $($SshKeyName)"
        $SshKey = New-AzSshKey -ResourceGroupName $ResourceGroup -Name $SshKeyName -PublicKey $PKContent
        New-AzTag -ResourceId $SshKey.Id -Tag $Tags
    }
    Write-Host "SSH Key Resource: $($SshKey.Name)"
    return $SshKey
}


function GetOrCreate_VirtualMachine {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroup,
        [Parameter(Mandatory=$true)]
        [hashtable]$Tags,
        [Parameter(Mandatory=$true)]
        [array]$NetworkInterfaces,
        [Parameter(Mandatory=$true)]
        [string]$SshKeyName,
        [Parameter(Mandatory=$true)]
        [string]$Location,
        [Parameter(Mandatory=$true)]
        [string]$ApplicationId,
        [Parameter(Mandatory=$true)]
        [int]$Count
    )

    Write-Host "Get or Create new Virtual Machine"
    $VirtualMachinePrefix = "vm" + $ApplicationId
    $VirtualMachines = @()
    for ($i = 1; $i -le $Count; $i++) {
        $VirtualMachineName = $VirtualMachinePrefix + $i
        $VirtualMachine = Get-AzVM -Name $VirtualMachineName -ResourceGroupName $ResourceGroup -ErrorAction SilentlyContinue
        if ($null -eq $VirtualMachine) {
            $NetworkInterface = $NetworkInterfaces[$i-1]
            $VMSize = "Standard_DS2_v2"
            $OSCommonProps = @{
                PublisherName = "Canonical"
                Offer = "0001-com-ubuntu-server-jammy"
                Skus = "22_04-lts-gen2"
                Version = "latest"
            }

            $ComputerName = "$($ApplicationId)vmpc$($i)"
            $Username = "crivera"
            $SecurePassword = ' ' | ConvertTo-SecureString -AsPlainText -Force
            $Credentials = New-Object System.Management.Automation.PSCredential ($Username, $SecurePassword)

            $VMConfig = New-AzVMConfig -VMName $VirtualMachineName -VMSize $VMSize -SecurityType Standard -Tags $Tags
            Set-AzVMSourceImage -VM $VMConfig @OSCommonProps
            Set-AzVMOperatingSystem -VM $VMConfig -Linux -ComputerName $ComputerName -Credential $Credentials -DisablePasswordAuthentication
            Set-AzVMBootDiagnostic -VM $VMConfig -Disable
            $VMConfig = Add-AzVMNetworkInterface -VM $VMConfig -NetworkInterface $NetworkInterface

            Write-Host "Creating new Virtual Machine: $($VirtualMachineName)"
            $VirtualMachine = New-AzVM -VM $VMConfig -ResourceGroupName $ResourceGroup -Location $Location -Tag $Tags -SshKeyName $SshKeyName -ErrorAction Break
            Write-Host "Virtual Machine: $($VirtualMachineName)"
        }
        $VirtualMachines += $VirtualMachine
    }
    return $VirtualMachines
}