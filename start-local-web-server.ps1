# Define the service name
$mysqlServiceName = "MySQL80"
$xamppPath = "C:\xampp"

# Function to start a service
function Start-ServiceIfNotRunning {
    param (
        [string]$serviceName
    )
    # Get the status of the service
    try {
        $service = Get-Service -Name $serviceName -ErrorAction Stop
    } catch {
        Write-Host "Service $serviceName does not exist."
        return
    }

    if ($service.Status -ne 'Running') {
        Write-Host "Service $serviceName is not running. Attempting to start..."
        try {
            Start-Service -Name $serviceName -ErrorAction Stop
            # Check the status again after attempting to start
            $service = Get-Service -Name $serviceName
            if ($service.Status -eq 'Running') {
                Write-Host "Service $serviceName has been started successfully."
            } else {
                Write-Host "Failed to start service $serviceName."
            }
        } catch {
            Write-Host "Error: $($_.Exception.Message)"
            # Log the detailed error
            $_.Exception | Out-File -FilePath "C:\PowerShell Scripts\start-local-web-server\log\${serviceName}ServiceError.log" -Append
        }
    } else {
        Write-Host "Service $serviceName is already running."
    }
}

try {
    # Start MySQL service
    Start-ServiceIfNotRunning -serviceName $mysqlServiceName

    # Start Apache using XAMPP executable
    Write-Host "Starting Apache using XAMPP control..."
    $xamppControl = Join-Path -Path $xamppPath -ChildPath "xampp-control.exe"
    Start-Process -FilePath $xamppControl
    Write-Host "Apache should be started."

    # Exit the script if no error occurs
    exit 0
} catch {
    Write-Host "An error occurred: $($_.Exception.Message)"
    # Keep the window open to show the error message
    pause
    exit 1
}