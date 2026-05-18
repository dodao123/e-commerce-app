$PORT = 8081

Write-Host "Checking process using port $PORT ..."

$connections = Get-NetTCPConnection -LocalPort $PORT -ErrorAction Sil

if (!$connections) {
    Write-Host "No service is running on port $PORT"
} else {
    $pids = $connections | Select-Object -ExpandProperty OwningProcess -Unique

    foreach ($processId in $pids) {
        if ([string]::IsNullOrWhiteSpace($processId)) { continue }
        Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
    }

    Write-Host "Port $PORT has been freed"
}
