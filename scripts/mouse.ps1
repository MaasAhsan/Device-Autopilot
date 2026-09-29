# Device Autopilot — mouse, keyboard, screenshot (Windows, no Python).
# Claude Code: run ONE action, then screenshot to verify.
#
#   .\scripts\mouse.ps1 status
#   .\scripts\mouse.ps1 screenshot
#   .\scripts\mouse.ps1 pos
#   .\scripts\mouse.ps1 move 400 300
#   .\scripts\mouse.ps1 click 400 300
#   .\scripts\mouse.ps1 click          # click where the cursor already is
#   .\scripts\mouse.ps1 rightclick 400 300
#   .\scripts\mouse.ps1 doubleclick 400 300
#   .\scripts\mouse.ps1 scroll -120    # negative = down
#   .\scripts\mouse.ps1 type "hello"
#   .\scripts\mouse.ps1 key "^t"       # SendKeys: ^ ctrl, + shift, % alt

param(
    [Parameter(Position = 0)]
    [ValidateSet("status", "screenshot", "pos", "move", "click", "rightclick", "doubleclick", "scroll", "type", "key")]
    [string]$Action = "status",
    [Parameter(Position = 1)]
    [string]$A = "",
    [Parameter(Position = 2)]
    [string]$B = ""
)

$ErrorActionPreference = "Stop"

Add-Type @"
using System;
using System.Runtime.InteropServices;
public struct POINT { public int X; public int Y; }
public class DAInput {
    [DllImport("user32.dll")] public static extern bool SetCursorPos(int X, int Y);
    [DllImport("user32.dll")] public static extern bool GetCursorPos(out POINT lpPoint);
    [DllImport("user32.dll")] public static extern void mouse_event(uint flags, uint dx, uint dy, uint data, UIntPtr extra);
    public const uint LEFTDOWN = 0x0002;
    public const uint LEFTUP = 0x0004;
    public const uint RIGHTDOWN = 0x0008;
    public const uint RIGHTUP = 0x0010;
    public const uint WHEEL = 0x0800;
}
"@ | Out-Null

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Get-Screen {
    $b = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    return @{ X = $b.X; Y = $b.Y; W = $b.Width; H = $b.Height }
}

function Get-Pos {
    $p = New-Object POINT
    [void][DAInput]::GetCursorPos([ref]$p)
    return $p
}

function Move-To([int]$X, [int]$Y) {
    $s = Get-Screen
    if ($X -lt $s.X) { $X = $s.X }
    if ($Y -lt $s.Y) { $Y = $s.Y }
    if ($X -gt ($s.X + $s.W - 1)) { $X = $s.X + $s.W - 1 }
    if ($Y -gt ($s.Y + $s.H - 1)) { $Y = $s.Y + $s.H - 1 }
    [void][DAInput]::SetCursorPos($X, $Y)
}

function Click-Flags([uint32]$Down, [uint32]$Up) {
    [DAInput]::mouse_event($Down, 0, 0, 0, [UIntPtr]::Zero)
    Start-Sleep -Milliseconds 30
    [DAInput]::mouse_event($Up, 0, 0, 0, [UIntPtr]::Zero)
}

function Save-Shot {
    $dir = Join-Path $env:TEMP "device-autopilot"
    New-Item -ItemType Directory -Force $dir | Out-Null
    $path = Join-Path $dir ("shot-{0:yyyyMMdd-HHmmss}.png" -f (Get-Date))
    $s = Get-Screen
    $bmp = New-Object System.Drawing.Bitmap $s.W, $s.H
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.CopyFromScreen($s.X, $s.Y, 0, 0, $bmp.Size)
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
    return $path
}

switch ($Action) {
    "status" {
        $s = Get-Screen
        $p = Get-Pos
        "ok: windows mouse ready"
        "screen: $($s.W)x$($s.H) at $($s.X),$($s.Y)"
        "cursor: $($p.X),$($p.Y)"
    }
    "pos" {
        $p = Get-Pos
        "ok: $($p.X),$($p.Y)"
    }
    "screenshot" {
        $path = Save-Shot
        "ok: $path"
    }
    "move" {
        if ($A -eq "" -or $B -eq "") { throw "move needs X Y" }
        Move-To ([int]$A) ([int]$B)
        $p = Get-Pos
        "ok: moved $($p.X),$($p.Y)"
    }
    "click" {
        if ($A -ne "" -and $B -ne "") { Move-To ([int]$A) ([int]$B); Start-Sleep -Milliseconds 40 }
        Click-Flags 0x0002 0x0004
        $p = Get-Pos
        "ok: left click $($p.X),$($p.Y)"
    }
    "rightclick" {
        if ($A -ne "" -and $B -ne "") { Move-To ([int]$A) ([int]$B); Start-Sleep -Milliseconds 40 }
        Click-Flags 0x0008 0x0010
        $p = Get-Pos
        "ok: right click $($p.X),$($p.Y)"
    }
    "doubleclick" {
        if ($A -ne "" -and $B -ne "") { Move-To ([int]$A) ([int]$B); Start-Sleep -Milliseconds 40 }
        Click-Flags 0x0002 0x0004
        Start-Sleep -Milliseconds 60
        Click-Flags 0x0002 0x0004
        $p = Get-Pos
        "ok: double click $($p.X),$($p.Y)"
    }
    "scroll" {
        if ($A -eq "") { throw "scroll needs a wheel delta (e.g. -120)" }
        $delta = [uint32]([int]$A -band 0xFFFFFFFF)
        [DAInput]::mouse_event(0x0800, 0, 0, $delta, [UIntPtr]::Zero)
        "ok: scroll $A"
    }
    "type" {
        if ($A -eq "") { throw "type needs text" }
        # SendKeys treats +^%~(){} as special; wrap literals
        $escaped = [regex]::Replace($A, '[+\^%~(){}\[\]]', '{$0}')
        [System.Windows.Forms.SendKeys]::SendWait($escaped)
        "ok: typed"
    }
    "key" {
        if ($A -eq "") { throw "key needs a SendKeys string, e.g. ^t or {ENTER}" }
        [System.Windows.Forms.SendKeys]::SendWait($A)
        "ok: key $A"
    }
}
