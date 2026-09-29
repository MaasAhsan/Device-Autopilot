# Install Device Autopilot for Claude Code on Windows.
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Dest = Join-Path $env:USERPROFILE ".claude\skills\device-autopilot"

New-Item -ItemType Directory -Force $Dest | Out-Null
New-Item -ItemType Directory -Force (Join-Path $Dest "scripts") | Out-Null

Copy-Item (Join-Path $Root "skills\device-autopilot\SKILL.md") (Join-Path $Dest "SKILL.md") -Force
Copy-Item (Join-Path $Root "scripts\open_web.ps1") (Join-Path $Dest "scripts\open_web.ps1") -Force
Copy-Item (Join-Path $Root "scripts\mouse.ps1") (Join-Path $Dest "scripts\mouse.ps1") -Force
Copy-Item (Join-Path $Root "scripts\da_core.ps1") (Join-Path $Dest "scripts\da_core.ps1") -Force
Copy-Item (Join-Path $Root "scripts\da_server.ps1") (Join-Path $Dest "scripts\da_server.ps1") -Force
if (Test-Path (Join-Path $Root "scripts\open_web.sh")) {
    Copy-Item (Join-Path $Root "scripts\open_web.sh") (Join-Path $Dest "scripts\open_web.sh") -Force
}

Write-Host "Installed to $Dest"
Write-Host "Open a new Claude Code session, then try:"
Write-Host "  open youtube and search for cats"
Write-Host ""
Write-Host "Self-test:"
Write-Host "  powershell -ExecutionPolicy Bypass -File `"$Dest\scripts\open_web.ps1`" -Url https://www.youtube.com/"
Write-Host "  powershell -ExecutionPolicy Bypass -File `"$Dest\scripts\mouse.ps1`" status"
