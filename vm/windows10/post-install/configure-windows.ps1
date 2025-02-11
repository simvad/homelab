# Run as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run as Administrator"
    exit 1
}

# Disable unnecessary services
Write-Host "Disabling unnecessary services..."
$services = @(
    "DiagTrack"                                 # Connected User Experiences and Telemetry
    "dmwappushservice"                         # Device Management Wireless Application Protocol
    "HomeGroupListener"                        # HomeGroup Listener
    "HomeGroupProvider"                        # HomeGroup Provider
    "lfsvc"                                    # Geolocation Service
    "MapsBroker"                               # Downloaded Maps Manager
    "NetTcpPortSharing"                        # Net.Tcp Port Sharing Service
    "RemoteAccess"                             # Routing and Remote Access
    "RemoteRegistry"                           # Remote Registry
    "SharedAccess"                             # Internet Connection Sharing
    "TrkWks"                                   # Distributed Link Tracking Client
    "WbioSrvc"                                 # Windows Biometric Service
    "WMPNetworkSvc"                            # Windows Media Player Network Sharing Service
    "wscsvc"                                   # Security Center Service
)

foreach ($service in $services) {
    Set-Service -Name $service -StartupType Disabled
    Stop-Service -Name $service -Force
    Write-Host "Disabled service: $service"
}

# Optimize performance settings
Write-Host "Optimizing performance settings..."
$computerSystem = Get-WmiObject Win32_ComputerSystem
$computerSystem.AutomaticManagedPagefile = $false
$computerSystem.Put()

$pagefile = Get-WmiObject Win32_PageFileSetting
$pagefile.InitialSize = 8192
$pagefile.MaximumSize = 8192
$pagefile.Put()

# Power settings
Write-Host "Configuring power settings..."
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c # High performance
powercfg /change monitor-timeout-ac 0
powercfg /change standby-timeout-ac 0
powercfg /change hibernate-timeout-ac 0

# Network optimization
Write-Host "Optimizing network settings..."
Set-NetTCPSetting -SettingName InternetCustom -AutoTuningLevelLocal Normal
Set-NetTCPSetting -SettingName InternetCustom -ScalingHeuristics Disabled
Set-NetOffloadGlobalSetting -ReceiveSegmentCoalescing Enabled
Set-NetOffloadGlobalSetting -ReceiveSideScaling Enabled

# Disable Windows Defender (since this is a dev VM)
Write-Host "Configuring Windows Defender..."
Set-MpPreference -DisableRealtimeMonitoring $true
Set-MpPreference -DisableBehaviorMonitoring $true
Set-MpPreference -DisableBlockAtFirstSeen $true

# Configure development environment variables
Write-Host "Setting up environment variables..."
[Environment]::SetEnvironmentVariable("DOTNET_CLI_TELEMETRY_OPTOUT", "1", "Machine")
[Environment]::SetEnvironmentVariable("POWERSHELL_TELEMETRY_OPTOUT", "1", "Machine")
[Environment]::SetEnvironmentVariable("HOMEBUILD_PATH", "B:\", "Machine")

# Configure file associations
Write-Host "Configuring file associations..."
cmd /c "ftype txtfile=code.exe %1"
cmd /c "ftype Microsoft.VisualStudio.Launcher.sln=code.exe %1"
cmd /c "ftype VSCode.txt=code.exe %1"
cmd /c "ftype VSCode.cs=code.exe %1"

# Create desktop shortcuts
Write-Host "Creating desktop shortcuts..."
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\Build Directory.lnk")
$Shortcut.TargetPath = "B:\"
$Shortcut.Save()

# Configure system settings
Write-Host "Configuring system settings..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSuperHidden" -Value 1

Write-Host "Windows configuration complete. Restart machine to complete"