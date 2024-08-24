# PowerShell Script to Update Device Drivers

# Function to log messages with timestamp
function Log-Message {
    param (
        [string]$Message,
        [switch]$Error
    )
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    if ($Error) {
        Write-Error "$timestamp - $Message"
    } else {
        Write-Host "$timestamp - $Message"
    }
}

# Function to list all disk drives and their statuses
function List-DiskDrives {
    try {
        $diskDrives = Get-WmiObject -Class Win32_DiskDrive | Sort-Object -Property DeviceID
        if ($diskDrives.Count -gt 0) {
            $diskDrives | Format-Table -Property DeviceID, Model, InterfaceType, Size, Status -AutoSize
            Log-Message "Disk drives listed successfully."
        } else {
            Log-Message "No disk drives found."
        }
    } catch {
        Log-Message "Failed to retrieve disk drives: $_" -Error
    }
}

# Function to update disk drivers
function Update-DiskDrivers {
    try {
        Log-Message "Starting disk driver update."

        # Use Device Manager to force a rescan for updated drivers
        $devices = Get-WmiObject -Class Win32_DiskDrive
        foreach ($device in $devices) {
            $deviceID = $device.PNPDeviceID
            Log-Message "Updating driver for disk: $($device.Model) ($deviceID)"
            
            # Invoke Device Manager for driver updates
            Start-Process -FilePath "devmgmt.msc" -ArgumentList "/rescan" -Wait -NoNewWindow | Out-Null
            Log-Message "Driver update process initiated for device: $($device.Model)"
        }

        Log-Message "Disk driver update process completed."
    } catch {
        Log-Message "Failed to update disk drivers: $_" -Error
    }
}

# Function to run Windows Troubleshooter for hardware
function Run-HardwareTroubleshooter {
    try {
        Log-Message "Starting hardware troubleshooter."

        # Run the hardware troubleshooter
        Start-Process -FilePath "msdt.exe" -ArgumentList "/id DeviceDiagnostic" -Wait -NoNewWindow
        Log-Message "Hardware troubleshooter completed."
    } catch {
        Log-Message "Failed to run hardware troubleshooter: $_" -Error
    }
}

# Run automated disk management and troubleshooting
function Run-Automated-Disk-Management {
    List-DiskDrives
    Update-DiskDrivers
    Run-HardwareTroubleshooter
    Log-Message "Automated disk management and troubleshooting completed."
}

# Execute the automated disk management and troubleshooting
Run-Automated-Disk-Management
