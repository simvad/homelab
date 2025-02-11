# Run as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run as Administrator"
    exit 1
}

# Configuration
$BuildToolsUrl = "https://aka.ms/vs/17/release/vs_buildtools.exe"
$GitUrl = "https://github.com/git-for-windows/git/releases/download/v2.42.0.windows.2/Git-2.42.0.2-64-bit.exe"
$NodeUrl = "https://nodejs.org/dist/v20.11.0/node-v20.11.0-x64.msi"

# Enable Windows features
Write-Host "Enabling Windows features..."
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart

# Install Chocolatey
Write-Host "Installing Chocolatey..."
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install development tools
Write-Host "Installing development tools..."
choco install -y `
    vscode `
    dotnet-sdk `
    python `
    git `
    nodejs `
    docker-desktop `
    microsoft-windows-terminal

# Install Visual Studio Build Tools
Write-Host "Installing Visual Studio Build Tools..."
Invoke-WebRequest -Uri $BuildToolsUrl -OutFile "$env:TEMP\vs_buildtools.exe"
Start-Process -Wait -FilePath "$env:TEMP\vs_buildtools.exe" -ArgumentList "--quiet --wait --norestart --nocache `
    --installPath C:\BuildTools `
    --add Microsoft.VisualStudio.Workload.MSBuildTools `
    --add Microsoft.VisualStudio.Workload.NetCoreBuildTools `
    --add Microsoft.VisualStudio.Workload.VCTools"

# Mount build artifacts directory
$BuildPath = "B:"
if (!(Test-Path $BuildPath)) {
    Write-Host "Mounting build artifacts drive..."
    New-PSDrive -Name "B" -PSProvider FileSystem -Root "\\vfsshare\build" -Persist
}

# Configure Git
Write-Host "Configuring Git..."
git config --global core.autocrlf true
git config --global user.name "Homelab Developer"
git config --global user.email "dev@homelab.local"

# Configure Windows Terminal
Write-Host "Configuring Windows Terminal..."
$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$settings = Get-Content $settingsPath | ConvertFrom-Json
$settings.defaultProfile = "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}" # PowerShell
$settings.profiles.list[0].colorScheme = "One Half Dark"
$settings | ConvertTo-Json -Depth 32 | Set-Content $settingsPath

# Configure VSCode
Write-Host "Configuring VSCode..."
code --install-extension ms-dotnettools.csharp
code --install-extension ms-vscode.powershell
code --install-extension ms-vscode.cpptools
code --install-extension ms-azuretools.vscode-docker

Write-Host "Development tools setup complete!"