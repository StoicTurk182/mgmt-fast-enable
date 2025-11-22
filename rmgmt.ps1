# Enable-PSRemoting.ps1
# Run this ON the remote machine (ORION-I) with Administrator privileges

Write-Host "=== Enabling PowerShell Remoting on Remote Machine ===" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}

try {
    # Enable PS Remoting
    Write-Host "1. Enabling PowerShell Remoting..." -ForegroundColor Yellow
    Enable-PSRemoting -Force -SkipNetworkProfileCheck
    Write-Host "   ✓ PS Remoting enabled" -ForegroundColor Green

    # Configure WinRM service
    Write-Host "2. Configuring WinRM service..." -ForegroundColor Yellow
    Set-Service WinRM -StartupType Automatic
    Start-Service WinRM
    Write-Host "   ✓ WinRM service configured and started" -ForegroundColor Green

    # Set WinRM to allow remote connections
    Write-Host "3. Configuring WinRM settings..." -ForegroundColor Yellow
    winrm quickconfig -force -quiet
    Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force
    Write-Host "   ✓ WinRM configured to accept remote connections" -ForegroundColor Green

    # Configure firewall rules
    Write-Host "4. Configuring Windows Firewall..." -ForegroundColor Yellow
    Enable-NetFirewallRule -DisplayGroup "Windows Remote Management"
    Write-Host "   ✓ Firewall rules enabled for WinRM" -ForegroundColor Green

    # Optional: Allow specific authentication
    Write-Host "5. Configuring authentication..." -ForegroundColor Yellow
    Set-Item WSMan:\localhost\Service\Auth\Basic -Value $true
    Set-Item WSMan:\localhost\Service\Auth\Negotiate -Value $true
    Set-Item WSMan:\localhost\Service\Auth\Kerberos -Value $true
    Write-Host "   ✓ Authentication configured" -ForegroundColor Green

    # Test local listener
    Write-Host "6. Testing WinRM listener..." -ForegroundColor Yellow
    $listener = Get-WSManInstance -ResourceURI winrm/config/listener -SelectorSet @{Address="*";Transport="HTTP"}
    if ($listener) {
        Write-Host "   ✓ WinRM listener is active on port $($listener.Port)" -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "=== SUCCESS: Remote machine is now configured! ===" -ForegroundColor Green
    Write-Host "Machine Name: $env:COMPUTERNAME" -ForegroundColor White
    Write-Host ""
    
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Read-Host "Press Enter to exit"