#Install WinGet
#Based on this gist: https://gist.github.com/crutkas/6c2096eae387e544bd05cde246f23901
$hasPackageManager = Get-AppPackage -name 'Microsoft.DesktopAppInstaller'
if (!$hasPackageManager -or [version]$hasPackageManager.Version -lt [version]"1.10.0.0") {
    "Installing winget Dependencies"
    Add-AppxPackage -Path 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx'

    $releases_url = 'https://api.github.com/repos/microsoft/winget-cli/releases/latest'

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $releases = Invoke-RestMethod -uri $releases_url
    $latestRelease = $releases.assets | Where-Object { $_.browser_download_url.EndsWith('msixbundle') } | Select-Object -First 1

    "Installing winget from $($latestRelease.browser_download_url)"
    Add-AppxPackage -Path $latestRelease.browser_download_url
}

#Configure WinGet
Write-Output "Configuring winget"

#winget config path from: https://github.com/microsoft/winget-cli/blob/master/doc/Settings.md#file-location
$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json";
$settingsJson = @"
{
    "experimentalFeatures": {
        "experimentalMSStore": true,
    }
}
"@;
$settingsJson | Out-File $settingsPath -Encoding utf8

#Install New apps
Write-Output "Installing Apps"
$apps = @(
    @{name = "Microsoft.AzureCLI" }, 
    @{name = "Microsoft.VisualStudioCode" }, 
    @{name = "Microsoft.WindowsTerminal"; source = "msstore" }, 
    @{name = "Microsoft.PowerToys" }, 
    @{name = "Git.Git" }, 
    @{name = "Docker.DockerDesktop" },
    @{name = "Microsoft.DotNet.SDK.7"  },
    @{name = "Microsoft.DotNet.SDK.8" },
    @{name = "Canonical.Ubuntu.2204" },
    @{name = "GitHub.cli" },
    @{name = "GitHub.GitHubDesktop" },
    @{name = "Python.Python.3.10" },
    @{name = "Node.js" }
);
Foreach ($app in $apps) {
    $listApp = winget list --exact -q $app.name --accept-source-agreements 
    if (![String]::Join("", $listApp).Contains($app.name)) {
        Write-host "Installing:" $app.name
        if ($null -ne $app.source) {
            winget install --exact --silent $app.name --source $app.source --accept-package-agreements --accept-source-agreements
        }
        else {
            winget install --exact --silent $app.name --accept-package-agreements --accept-source-agreements
        }
    }
    else {
        Write-host "Skipping Install of " $app.name
    }
}

#Setup WSL
wsl --install