# PowerShell Script to Detect and Report GPU Information

# Function to check if the script is running with elevated permissions
function Test-Admin {
    try {
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch {
        return $false
    }
}

if (-not (Test-Admin)) {
    Write-Output "This script requires elevated permissions. Please run PowerShell as an Administrator."
    exit
}

# Function to retrieve and display GPU information
function Get-GPUInfo {
    Write-Output "Gathering GPU information..."

    # Get GPU information using WMI
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
}

# Function to check GPU utilization using DirectX diagnostic tool
function Get-DirectXGPUInfo {
    Write-Output "Gathering DirectX GPU information..."
    $dxDiagPath = "$env:temp\dxdiag.txt"

    Start-Process -FilePath "dxdiag.exe" -ArgumentList "/t $dxDiagPath" -NoNewWindow -Wait

    if (Test-Path $dxDiagPath) {
        $dxDiagOutput = Get-Content $dxDiagPath -Raw
        Write-Output "-------------------------------------------------"
        Write-Output "DirectX Diagnostic Information:"
        Write-Output $dxDiagOutput
        Write-Output "-------------------------------------------------"
        Remove-Item $dxDiagPath
    } else {
        Write-Output "Failed to run DirectX Diagnostic Tool."
    }
}

# Execute the functions
Get-GPUInfo
Get-DirectXGPUInfo
