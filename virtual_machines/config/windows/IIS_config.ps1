Import-Module servermanager

Add-WindowsFeature web-server -includeallsubfeature
Add-WindowsFeature Web-Asp-Net45
Add-WindowsFeature NET-Framework-features
Set-Content -Path "C:\inetpub\wwwrot\Default.html" -Value `
"This is the server $($env:COMPUTERNAME)"