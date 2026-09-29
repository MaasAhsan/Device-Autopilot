# Open any URL or web search in a chosen Windows browser.
#
#   powershell -ExecutionPolicy Bypass -File .\scripts\open_web.ps1 -Url https://example.com -Browser chrome
#   powershell -ExecutionPolicy Bypass -File .\scripts\open_web.ps1 -Search "lo-fi beats" -Engine youtube -Browser opera-gx

param(
    [string]$Url = "",
    [string]$Search = "",
    [ValidateSet("youtube", "google", "bing", "duckduckgo", "none")]
    [string]$Engine = "google",
    [string]$Browser = "default"
)

$ErrorActionPreference = "Stop"

function Find-Browser([string]$Key) {
    $k = $Key.ToLower().Trim()
    switch ($k) {
        { $_ -in @("opera-gx", "operagx", "opera gx") } { $k = "opera-gx" }
        { $_ -in @("google-chrome", "google chrome") } { $k = "chrome" }
        { $_ -in @("msedge", "microsoft edge") } { $k = "edge" }
        { $_ -in @("brave-browser") } { $k = "brave" }
    }
    $map = @{
        "opera-gx" = @(
            "$env:LOCALAPPDATA\Programs\Opera GX\opera.exe",
            "$env:LOCALAPPDATA\Programs\Opera GX\launcher.exe",
            "$env:PROGRAMFILES\Opera GX\opera.exe",
            "${env:PROGRAMFILES(X86)}\Opera GX\opera.exe"
        )
        "opera" = @(
            "$env:LOCALAPPDATA\Programs\Opera\opera.exe",
            "$env:PROGRAMFILES\Opera\opera.exe"
        )
        "chrome" = @(
            "$env:PROGRAMFILES\Google\Chrome\Application\chrome.exe",
            "${env:PROGRAMFILES(X86)}\Google\Chrome\Application\chrome.exe",
            "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
        )
        "edge" = @(
            "$env:PROGRAMFILES\Microsoft\Edge\Application\msedge.exe",
            "${env:PROGRAMFILES(X86)}\Microsoft\Edge\Application\msedge.exe"
        )
        "firefox" = @(
            "$env:PROGRAMFILES\Mozilla Firefox\firefox.exe",
            "${env:PROGRAMFILES(X86)}\Mozilla Firefox\firefox.exe"
        )
        "brave" = @(
            "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\Application\brave.exe"
        )
    }
    if ($k -eq "default") { return $null }
    $list = $map[$k]
    if ($list) {
        foreach ($p in $list) {
            if (Test-Path $p) { return $p }
        }
    }
    return $null
}

function Build-SearchUrl([string]$Query, [string]$Eng) {
    $q = [uri]::EscapeDataString($Query.Trim())
    switch ($Eng.ToLower()) {
        "youtube" { return "https://www.youtube.com/results?search_query=$q" }
        "bing" { return "https://www.bing.com/search?q=$q" }
        "duckduckgo" { return "https://duckduckgo.com/?q=$q" }
        default { return "https://www.google.com/search?q=$q" }
    }
}

if ($Search -and $Search.Trim().Length -gt 0) {
    $target = Build-SearchUrl $Search $Engine
} elseif ($Url -and $Url.Trim().Length -gt 0) {
    $target = $Url.Trim()
    if ($target -notmatch "^https?://") { $target = "https://$target" }
} else {
    Write-Error "Pass -Url or -Search."
    exit 2
}

$exe = Find-Browser $Browser
if ($exe) {
    Start-Process -FilePath $exe -ArgumentList $target
    Write-Output "ok: $exe"
    Write-Output "url: $target"
    exit 0
}

if ($Browser -ne "default" -and $Browser.Trim().Length -gt 0) {
    Write-Output "warn: browser '$Browser' not found; using default"
}

Start-Process $target
Write-Output "ok: default browser"
Write-Output "url: $target"
exit 0
