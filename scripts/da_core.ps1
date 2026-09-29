# Shared Windows input helpers. Dot-sourced by mouse.ps1 and da_server.ps1.

if (-not ("DAInput" -as [type])) {
    Add-Type @"
using System;
using System.Runtime.InteropServices;
public struct POINT { public int X; public int Y; }
public class DAInput {
    [DllImport("user32.dll")] public static extern bool SetCursorPos(int X, int Y);
    [DllImport("user32.dll")] public static extern bool GetCursorPos(out POINT lpPoint);
    [DllImport("user32.dll")] public static extern void mouse_event(uint flags, uint dx, uint dy, uint data, UIntPtr extra);
}
"@
}

function Get-DAPos {
    $p = New-Object POINT
    [void][DAInput]::GetCursorPos([ref]$p)
    return $p
}

function Move-DA([int]$X, [int]$Y) {
    [void][DAInput]::SetCursorPos($X, $Y)
}

function Click-DA([string]$Kind = "left") {
    switch ($Kind) {
        "right" { [DAInput]::mouse_event(0x0008, 0, 0, 0, [UIntPtr]::Zero); [DAInput]::mouse_event(0x0010, 0, 0, 0, [UIntPtr]::Zero) }
        default { [DAInput]::mouse_event(0x0002, 0, 0, 0, [UIntPtr]::Zero); [DAInput]::mouse_event(0x0004, 0, 0, 0, [UIntPtr]::Zero) }
    }
}

function Scroll-DA([int]$Delta) {
    $u = [uint32]($Delta -band 0xFFFFFFFF)
    [DAInput]::mouse_event(0x0800, 0, 0, $u, [UIntPtr]::Zero)
}

function Save-DAShot {
    if (-not ("System.Windows.Forms.Screen" -as [type])) {
        Add-Type -AssemblyName System.Windows.Forms
    }
    if (-not ("System.Drawing.Bitmap" -as [type])) {
        Add-Type -AssemblyName System.Drawing
    }
    $dir = Join-Path $env:TEMP "device-autopilot"
    New-Item -ItemType Directory -Force $dir | Out-Null
    $path = Join-Path $dir ("shot-{0:yyyyMMdd-HHmmss}.jpg" -f (Get-Date))
    $b = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    $bmp = New-Object System.Drawing.Bitmap $b.Width, $b.Height
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.CopyFromScreen($b.X, $b.Y, 0, 0, $bmp.Size)
    $g.Dispose()
    $maxW = 1280
    if ($bmp.Width -gt $maxW) {
        $h = [int]($bmp.Height * ($maxW / $bmp.Width))
        $small = New-Object System.Drawing.Bitmap $maxW, $h
        $g2 = [System.Drawing.Graphics]::FromImage($small)
        $g2.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::Low
        $g2.DrawImage($bmp, 0, 0, $maxW, $h)
        $g2.Dispose()
        $bmp.Dispose()
        $bmp = $small
    }
    $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
    $ep = New-Object System.Drawing.Imaging.EncoderParameters 1
    $ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality, [long]50)
    $bmp.Save($path, $codec, $ep)
    $bmp.Dispose()
    return $path
}
