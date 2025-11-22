# Windows Remote Management Configuration Script

## Overview
PowerShell script that enables and configures comprehensive remote management features on Windows systems. Performs pre-checks, configuration, and post-verification to ensure all remote management capabilities are properly enabled.

## Purpose
Automates the setup of Windows remote management features including PowerShell Remoting, WinRM, Remote Registry, and various firewall rules required for remote administration.

## Features

### Services Configured
- **PowerShell Remoting** - Enables `Invoke-Command` and `Enter-PSSession`
- **WinRM Service** - Windows Remote Management service
- **Remote Registry** - Remote registry access

### Firewall Rules Enabled
- File and Printer Sharing
- Network Discovery
- Remote Event Log Management
- Remote Service Management
- Remote Volume Management
- Remote Scheduled Tasks Management
- Windows Management Instrumentation (WMI)
- COM+ Network Access
- Performance Logs and Alerts
- Windows Firewall Remote Management
- Windows Remote Management

### Script Capabilities
- ✅ Pre-configuration status check
- ✅ User confirmation prompt
- ✅ Automatic configuration of all features
- ✅ Post-configuration verification
- ✅ Color-coded status indicators
- ✅ Error handling

## Requirements

### System Requirements
- **Operating System**: Windows 10/11 or Windows Server 2016+
- **PowerShell**: Version 5.1 or higher
- **Privileges**: Must run as Administrator

### Network Requirements
- Target machine must be accessible on the network
- Appropriate firewall rules on network devices (if applicable)

## Installation

1. Download `Enable-FullRemoteManagement.ps1`
2. Place in a convenient location (e.g., `C:\Scripts\`)
3. Right-click PowerShell and select "Run as Administrator"

## Usage

### Basic Usage
```powershell
# Navigate to script location
cd C:\Scripts

# Run the script
.\Enable-FullRemoteManagement.ps1
```

### What Happens
1. **Administrator Check** - Verifies script is running with admin privileges
2. **Pre-Check** - Displays current status of all features
3. **Confirmation** - Prompts user to proceed (Y/N)
4. **Configuration** - Enables all remote management features
5. **Verification** - Shows post-configuration status
6. **Summary** - Lists enabled capabilities

## Status Indicators

The script uses the following status codes:

| Indicator | Meaning |
|-----------|---------|
| `[OK]` | Feature is fully enabled and working |
| `[WARN]` | Feature is partially configured or has warnings |
| `[NO]` | Feature is disabled or not found |

## Remote Management Capabilities

Once configured, you can remotely manage the system using:

### PowerShell Remoting
```powershell
# Interactive session
Enter-PSSession -ComputerName COMPUTERNAME

# Execute single command
Invoke-Command -ComputerName COMPUTERNAME -ScriptBlock { Get-Process }

# Execute script
Invoke-Command -ComputerName COMPUTERNAME -FilePath C:\script.ps1
```

### Computer Management Console
```powershell
# Open Computer Management for remote computer
compmgmt.msc
# File > Connect to another computer
```

### Event Viewer
```powershell
# Connect to remote Event Viewer
eventvwr.msc
# Action > Connect to Another Computer
```

### Services Management
```powershell
# Manage remote services
Get-Service -ComputerName COMPUTERNAME
Start-Service -ComputerName COMPUTERNAME -Name ServiceName
```

### Registry Editor
```powershell
# Connect to remote registry
regedit
# File > Connect Network Registry
```

### Disk Management
```powershell
# Open Disk Management
diskmgmt.msc
# Action > Connect to another computer
```

### Task Scheduler
```powershell
# Connect to remote Task Scheduler
taskschd.msc
# Action > Connect to Another Computer
```

## Client-Side Configuration

For the **computer you're connecting FROM**, run:
```powershell
# Add target to TrustedHosts
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "COMPUTERNAME" -Force

# Or allow all (less secure)
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force

# Restart WinRM
Restart-Service WinRM

# Test connection
Test-WSMan -ComputerName COMPUTERNAME
```

## Troubleshooting

### Script Won't Run
**Issue**: "Execution policy prevents script from running"
```powershell
# Check current policy
Get-ExecutionPolicy

# Set policy (run as Admin)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Connection Failed
**Issue**: "WinRM cannot complete the operation"

**Solution 1**: Verify WinRM is running
```powershell
Get-Service WinRM
Start-Service WinRM
```

**Solution 2**: Check TrustedHosts on client
```powershell
Get-Item WSMan:\localhost\Client\TrustedHosts
```

**Solution 3**: Test connectivity
```powershell
Test-WSMan -ComputerName COMPUTERNAME
Test-NetConnection -ComputerName COMPUTERNAME -Port 5985
```

### Access Denied
**Issue**: "Access is denied"

**Solutions**:
- Ensure you have admin rights on remote system
- Use explicit credentials:
```powershell
$cred = Get-Credential
Enter-PSSession -ComputerName COMPUTERNAME -Credential $cred
```

### Firewall Blocking
**Issue**: Connection timeout or firewall error

**Solution**: Verify firewall rules
```powershell
# Check if WinRM is allowed
Get-NetFirewallRule -DisplayGroup "Windows Remote Management"

# Enable if needed
Set-NetFirewallRule -DisplayGroup "Windows Remote Management" -Enabled True
```

## Security Considerations

### TrustedHosts Wildcard
Setting TrustedHosts to `*` allows connections to any computer. For production environments:
```powershell
# Add specific computers only
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "Server1,Server2,Server3" -Force
```

### Network Profiles
Script uses `-SkipNetworkProfileCheck` which enables remoting on Public networks. Consider:
- Using only on Private/Domain networks in production
- Implementing additional firewall restrictions
- Using VPN for remote access

### Authentication
For enhanced security:
```powershell
# Use CredSSP for credential delegation (when needed)
Enable-WSManCredSSP -Role Client -DelegateComputer "COMPUTERNAME"

# Use Kerberos authentication (domain environments)
Enter-PSSession -ComputerName COMPUTERNAME -Authentication Kerberos
```

## Common Use Cases

### Remote Disk Space Check
```powershell
Invoke-Command -ComputerName COMPUTERNAME -ScriptBlock {
    Get-WmiObject -Class Win32_LogicalDisk | 
    Where-Object {$_.Size -gt 0} | 
    Select-Object DeviceID, 
        @{Name="Size(GB)";Expression={[math]::Round($_.Size/1GB,2)}},
        @{Name="Free(GB)";Expression={[math]::Round($_.FreeSpace/1GB,2)}}
}
```

### Remote Service Management
```powershell
# Check service status
Get-Service -ComputerName COMPUTERNAME -Name ServiceName

# Restart service
Invoke-Command -ComputerName COMPUTERNAME -ScriptBlock {
    Restart-Service -Name ServiceName
}
```

### Remote Process Information
```powershell
Invoke-Command -ComputerName COMPUTERNAME -ScriptBlock {
    Get-Process | Sort-Object CPU -Descending | Select-Object -First 10
}
```

## Additional Configuration

### Enable Remote Desktop (Optional)
If you also need RDP access:
```powershell
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
```

### Configure WinRM Listener
For custom ports or HTTPS:
```powershell
# View current listeners
winrm enumerate winrm/config/listener

# Create HTTPS listener (requires certificate)
winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname="FQDN"; CertificateThumbprint="THUMBPRINT"}
```

## Integration with Existing Infrastructure

### Active Directory Domain
In domain environments, many features are pre-configured via Group Policy. This script is most useful for:
- Workgroup computers
- Test/development systems
- Non-domain-joined servers

### Automation
Include in deployment scripts:
```powershell
# Silent execution with automatic yes
$response = 'Y' | .\Enable-FullRemoteManagement.ps1
```

## Version History

### v1.0 (Current)
- Initial release
- Pre/post configuration checks
- Support for all major remote management features
- Color-coded status indicators
- User confirmation prompts
- Comprehensive error handling

## Support & Documentation

### Related Documentation
- [Microsoft PowerShell Remoting](https://docs.microsoft.com/en-us/powershell/scripting/learn/remoting/running-remote-commands)
- [WinRM Configuration](https://docs.microsoft.com/en-us/windows/win32/winrm/installation-and-configuration-for-windows-remote-management)
- [Network Discovery Settings](https://docs.microsoft.com/en-us/troubleshoot/windows-server/networking/configure-network-discovery)

### Common Commands Reference
```powershell
# Test remoting
Test-WSMan -ComputerName TARGET

# Enter remote session
Enter-PSSession -ComputerName TARGET

# Execute remote command
Invoke-Command -ComputerName TARGET -ScriptBlock { COMMAND }

# Copy file to remote
Copy-Item -Path LOCAL -Destination \\TARGET\C$\PATH

# View remote services
Get-Service -ComputerName TARGET

# Check remote event logs
Get-EventLog -LogName System -ComputerName TARGET -Newest 10
```

## License
[Specify your license here]

## Author
[Your Name/Organization]

## Contributing
[Contribution guidelines if applicable]

---

**Note**: Always test in a non-production environment first. Enabling remote management features can expose systems to additional attack vectors if not properly secured.