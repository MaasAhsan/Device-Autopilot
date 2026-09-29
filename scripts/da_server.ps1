# Keep .NET loaded. Claude Code should start this ONCE per session.
#   powershell -ExecutionPolicy Bypass -File .\scripts\da_server.ps1
# Then:
#   Invoke-RestMethod http://127.0.0.1:8765/status
#   Invoke-RestMethod http://127.0.0.1:8765/shot
#   Invoke-RestMethod "http://127.0.0.1:8765/click?x=400&y=300"
#   Invoke-RestMethod "http://127.0.0.1:8765/tap?x=400&y=300"

param([int]$Port = 8765)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "da_core.ps1")
Add-Type -AssemblyName System.Windows.Forms | Out-Null

$prefix = "http://127.0.0.1:$Port/"
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add($prefix)
try {
    $listener.Start()
} catch {
    Write-Output "error: could not bind $prefix — is it already running?"
    throw
}
Write-Output "ok: device-autopilot server $prefix"
Write-Output "stop: Ctrl+C in this window"

function Write-DAResponse($ctx, [string]$Body, [int]$Code = 200) {
    $buf = [Text.Encoding]::UTF8.GetBytes($Body)
    $ctx.Response.StatusCode = $Code
    $ctx.Response.ContentType = "text/plain; charset=utf-8"
    $ctx.Response.ContentLength64 = $buf.Length
    $ctx.Response.OutputStream.Write($buf, 0, $buf.Length)
    $ctx.Response.Close()
}

try {
    while ($listener.IsListening) {
        $ctx = $listener.GetContext()
        $path = $ctx.Request.Url.AbsolutePath.TrimEnd("/").ToLower()
        $q = $ctx.Request.QueryString
        try {
            switch ($path) {
                "/status" {
                    $p = Get-DAPos
                    Write-DAResponse $ctx "ok: server`ncursor: $($p.X),$($p.Y)"
                }
                "/pos" {
                    $p = Get-DAPos
                    Write-DAResponse $ctx "ok: $($p.X),$($p.Y)"
                }
                "/shot" { Write-DAResponse $ctx "ok: $(Save-DAShot)" }
                "/click" {
                    if ($q["x"] -and $q["y"]) { Move-DA ([int]$q["x"]) ([int]$q["y"]) }
                    Click-DA "left"
                    $p = Get-DAPos
                    Write-DAResponse $ctx "ok: left click $($p.X),$($p.Y)"
                }
                "/tap" {
                    if ($q["x"] -and $q["y"]) { Move-DA ([int]$q["x"]) ([int]$q["y"]) }
                    Click-DA "left"
                    Write-DAResponse $ctx "ok: tap`nshot: $(Save-DAShot)"
                }
                "/type" {
                    $t = $q["text"]
                    if (-not $t) { throw "text= required" }
                    $escaped = [regex]::Replace($t, '[+\^%~(){}\[\]]', '{$0}')
                    [System.Windows.Forms.SendKeys]::SendWait($escaped)
                    Write-DAResponse $ctx "ok: typed"
                }
                "/key" {
                    $k = $q["combo"]
                    if (-not $k) { throw "combo= required" }
                    [System.Windows.Forms.SendKeys]::SendWait($k)
                    Write-DAResponse $ctx "ok: key $k"
                }
                "/stop" {
                    Write-DAResponse $ctx "ok: stopping"
                    $listener.Stop()
                }
                default { Write-DAResponse $ctx "unknown $path" 404 }
            }
        } catch {
            Write-DAResponse $ctx "error: $($_.Exception.Message)" 500
        }
    }
} finally {
    if ($listener.IsListening) { $listener.Stop() }
    $listener.Close()
}
