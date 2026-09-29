# Fast-ish mouse/screenshot. Click does NOT load image libraries.
# Prefer da_server.ps1 if you will do many actions in a row.
#
#   .\scripts\mouse.ps1 status
#   .\scripts\mouse.ps1 screenshot
#   .\scripts\mouse.ps1 click 400 300
#   .\scripts\mouse.ps1 tap 400 300     # click + one screenshot (one process)
#   .\scripts\mouse.ps1 type "hello"
#   .\scripts\mouse.ps1 key "^t"

param(
    [Parameter(Position = 0)]
    [ValidateSet("status", "screenshot", "pos", "move", "click", "rightclick", "doubleclick", "scroll", "type", "key", "tap")]
    [string]$Action = "status",
    [Parameter(Position = 1)]
    [string]$A = "",
    [Parameter(Position = 2)]
    [string]$B = ""
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "da_core.ps1")

switch ($Action) {
    "status" {
        $p = Get-DAPos
        "ok: windows mouse ready"
        "cursor: $($p.X),$($p.Y)"
        "hint: start da_server.ps1 once to make later actions faster"
    }
    "pos" { $p = Get-DAPos; "ok: $($p.X),$($p.Y)" }
    "move" {
        if ($A -eq "" -or $B -eq "") { throw "move needs X Y" }
        Move-DA ([int]$A) ([int]$B)
        "ok: moved $A,$B"
    }
    "click" {
        if ($A -ne "" -and $B -ne "") { Move-DA ([int]$A) ([int]$B) }
        Click-DA "left"
        $p = Get-DAPos
        "ok: left click $($p.X),$($p.Y)"
    }
    "rightclick" {
        if ($A -ne "" -and $B -ne "") { Move-DA ([int]$A) ([int]$B) }
        Click-DA "right"
        "ok: right click"
    }
    "doubleclick" {
        if ($A -ne "" -and $B -ne "") { Move-DA ([int]$A) ([int]$B) }
        Click-DA "left"; Click-DA "left"
        "ok: double click"
    }
    "scroll" {
        if ($A -eq "") { throw "scroll needs delta, e.g. -120" }
        Scroll-DA ([int]$A)
        "ok: scroll $A"
    }
    "screenshot" { "ok: $(Save-DAShot)" }
    "tap" {
        if ($A -ne "" -and $B -ne "") { Move-DA ([int]$A) ([int]$B) }
        Click-DA "left"
        "ok: tap $A $B"
        "shot: $(Save-DAShot)"
    }
    "type" {
        if ($A -eq "") { throw "type needs text" }
        Add-Type -AssemblyName System.Windows.Forms
        $escaped = [regex]::Replace($A, '[+\^%~(){}\[\]]', '{$0}')
        [System.Windows.Forms.SendKeys]::SendWait($escaped)
        "ok: typed"
    }
    "key" {
        if ($A -eq "") { throw "key needs SendKeys, e.g. ^t" }
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.SendKeys]::SendWait($A)
        "ok: key $A"
    }
}
