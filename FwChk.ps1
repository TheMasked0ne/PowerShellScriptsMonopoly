## { PowerShell script to check if your motherboard firmware 
# is set to UEFI mode or Legacy}

function Check-FirmwareMode {
    try {
        # Query the system's firmware type using CIM
        $systemFirmware = Get-CimInstance -ClassName Win32_ComputerSystem

        if ($systemFirmware) {
            # Determine if the system is in UEFI mode
            if ($systemFirmware.FirmwareType -contains "UEFI") {
                Write-Output "The system is running in UEFI mode."
            } else {
                Write-Output "The system is running in Legacy mode."
            }
        } else {
            Write-Output "Unable to retrieve system information."
        }
    } catch {
        Write-Output "An error occurred: $_"
    }
}

# Run the function
Check-FirmwareMode
