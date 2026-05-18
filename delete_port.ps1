$PORT = 8081

Write-Host "Checking process using port $PORT ..."

$connections = Get-NetTCPConnection -LocalPort $PORT -ErrorAction Sil

if (!$connections) {
    Write-Host "No service is running on port $PORT"
} else {
    $pids = $connections | Select-Object -ExpandProperty OwningProcess -Unique

    foreach ($pid in $pids) {
        Write-Host "Killing process $pid ..."
        Stop-Process -Id $pid -Force
    }

    Write-Host "Port $PORT has been freed"
}
