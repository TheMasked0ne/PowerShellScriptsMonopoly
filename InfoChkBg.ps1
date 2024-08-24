# Ensure PowerShell scripts can run
Set-ExecutionPolicy Unrestricted -Scope Process -Force

# Function to check BIOS settings
function Check-BIOS {
    Write-Output "Checking BIOS settings..."

    # Check Secure Boot status
    try {
        $secureBoot = Get-WmiObject -Namespace "root\cimv2\security\microsofttpm" -Class Win32_Tpm | Select-Object -ExpandProperty IsActivated_InitialValue
        if ($secureBoot) {
            Write-Output "Secure Boot is enabled."
        } else {
            Write-Output "Secure Boot is disabled."
        }
    } catch {
        Write-Output "Failed to retrieve Secure Boot status. Error: $_"
    }

    # Check BIOS version
    try {
        $bios = Get-WmiObject -Class Win32_BIOS
        Write-Output "BIOS Manufacturer: $($bios.Manufacturer)"
        Write-Output "BIOS Version: $($bios.SMBIOSBIOSVersion)"
        Write-Output "BIOS Release Date: $($bios.ReleaseDate)"
    } catch {
        Write-Output "Failed to retrieve BIOS information. Error: $_"
    }
}

# Function to check system logs for errors
function Check-SystemLogs {
    Write-Output "Checking system logs..."

    try {
        $logs = Get-WinEvent -LogName System -MaxEvents 100 | Where-Object { $_.LevelDisplayName -eq "Error" }
        if ($logs.Count -eq 0) {
            Write-Output "No recent system errors found."
        } else {
            foreach ($log in $logs) {
                Write-Output "-------------------------------------------------"
                Write-Output "Time Created: $($log.TimeCreated)"
                Write-Output "Source: $($log.ProviderName)"
                Write-Output "Event ID: $($log.Id)"
                Write-Output "Message: $($log.Message)"
                Write-Output "-------------------------------------------------"
            }
        }
    } catch {
        Write-Output "Failed to retrieve system logs. Error: $_"
    }
}

# Function to check registry for common issues
function Check-Registry {
    Write-Output "Checking registry entries..."

    $registryPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
    )

    foreach ($path in $registryPaths) {
        if (Test-Path $path) {
            Write-Output "Registry path $path exists."
            try {
                $registryKeys = Get-ItemProperty -Path $path
                Write-Output "Keys under $path:"
                foreach ($key in $registryKeys.PSObject.Properties) {
                    Write-Output "    $($key.Name): $($key.Value)"
                }
            } catch {
                Write-Output "Failed to retrieve registry keys for path $path. Error: $_"
            }
        } else {
            Write-Output "Registry path $path is missing."
        }
    }
}

# Function to check for GPU details
function Check-GPU {
    Write-Output "Checking GPU details..."

    try {
        $gpus = Get-WmiObject Win32_VideoController
        if ($gpus.Count -eq 0) {
            Write-Output "No GPUs detected."
        } else {
            foreach ($gpu in $gpus) {
                Write-Output "-------------------------------------------------"
                Write-Output "Name: $($gpu.Name)"
                Write-Output "Device ID: $($gpu.DeviceID)"
                Write-Output "Adapter RAM: $([math]::Round($gpu.AdapterRAM / 1GB, 2)) GB"
                Write-Output "Driver Version: $($gpu.DriverVersion)"
                Write-Output "Status: $($gpu.Status)"
                Write-Output "-------------------------------------------------"
            }
        }
    } catch {
        Write-Output "Failed to retrieve GPU information. Error: $_"
    }
}

# Function to analyze and report issues
function Analyze-Issues {
    Write-Output "Starting system analysis..."

    Check-BIOS
    Check-SystemLogs
    Check-Registry
    Check-GPU

    Write-Output "Analysis complete. Please review the output for potential issues."
}

# Run the analysis
Analyze-Issues
