<#
.SYNOPSIS
Draws the OpenOSK application icon and writes src/OpenOsk/Assets/OpenOSK.ico.

.DESCRIPTION
The icon is a keyboard glyph (three rows of keys and a space bar) in white on a rounded
#0067C0 square, the accent colour of the light theme. Each frame is rendered at its own size
from the same geometry, so small sizes stay crisp instead of being blurred down from 256 px.
Frames are stored PNG-compressed, which every supported Windows version reads.

Needs only Windows PowerShell 5.1 or PowerShell 7 on Windows (System.Drawing).

.EXAMPLE
pwsh tools/New-Icon.ps1
#>
param(
    [string]$OutputPath = (Join-Path $PSScriptRoot "..\src\OpenOsk\Assets\OpenOSK.ico"),
    [int[]]$Sizes = @(16, 24, 32, 48, 64, 128, 256)
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

function New-Frame([int]$size) {
    $bmp = New-Object System.Drawing.Bitmap $size, $size, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)

    # Rounded square background.
    $s = [double]$size
    $radius = $s * 0.22
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $radius * 2
    $path.AddArc(0, 0, $d, $d, 180, 90)
    $path.AddArc($s - $d, 0, $d, $d, 270, 90)
    $path.AddArc($s - $d, $s - $d, $d, $d, 0, 90)
    $path.AddArc(0, $s - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    $blue = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 0, 103, 192))
    $g.FillPath($blue, $path)

    # Keys: three rows of 5, 5 and 4 keys, then a space bar, centred in the square.
    $white = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::White)
    $margin = $s * 0.16
    $inner = $s - (2 * $margin)
    $gap = [Math]::Max(1.0, $s * 0.035)
    $rows = 4
    $keyH = ($inner - ($gap * ($rows - 1))) / $rows
    $keyR = [Math]::Max(0.8, $keyH * 0.22)
    $layout = @(5, 5, 4)
    for ($r = 0; $r -lt $rows; $r++) {
        $y = $margin + ($r * ($keyH + $gap))
        if ($r -lt 3) {
            $n = $layout[$r]
            $keyW = ($inner - ($gap * ($n - 1))) / $n
            $offset = ($inner - (($keyW * $n) + ($gap * ($n - 1)))) / 2
            for ($c = 0; $c -lt $n; $c++) {
                $x = $margin + $offset + ($c * ($keyW + $gap))
                Add-RoundedRect $g $white $x $y $keyW $keyH $keyR
            }
        }
        else {
            # Space bar: as wide as the middle three keys of the top row.
            $keyW = ($inner - ($gap * 4)) / 5
            $x = $margin + $keyW + $gap
            $w = (3 * $keyW) + (2 * $gap)
            Add-RoundedRect $g $white $x $y $w $keyH $keyR
        }
    }

    $g.Dispose()
    return $bmp
}

function Add-RoundedRect($g, $brush, [double]$x, [double]$y, [double]$w, [double]$h, [double]$r) {
    $r = [Math]::Min($r, [Math]::Min($w, $h) / 2)
    if ($r -lt 0.5) { $g.FillRectangle($brush, [float]$x, [float]$y, [float]$w, [float]$h); return }
    $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $r * 2
    $p.AddArc([float]$x, [float]$y, [float]$d, [float]$d, 180, 90)
    $p.AddArc([float]($x + $w - $d), [float]$y, [float]$d, [float]$d, 270, 90)
    $p.AddArc([float]($x + $w - $d), [float]($y + $h - $d), [float]$d, [float]$d, 0, 90)
    $p.AddArc([float]$x, [float]($y + $h - $d), [float]$d, [float]$d, 90, 90)
    $p.CloseFigure()
    $g.FillPath($brush, $p)
}

# Render every frame to PNG bytes.
$frames = foreach ($size in $Sizes) {
    $bmp = New-Frame $size
    $ms = New-Object System.IO.MemoryStream
    $bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    [pscustomobject]@{ Size = $size; Bytes = $ms.ToArray() }
}

# ICO container: ICONDIR, one ICONDIRENTRY per frame, then the PNG payloads.
$out = New-Object System.IO.MemoryStream
$w = New-Object System.IO.BinaryWriter $out
$w.Write([uint16]0)              # reserved
$w.Write([uint16]1)              # type 1 = icon
$w.Write([uint16]$frames.Count)
$offset = 6 + (16 * $frames.Count)
foreach ($f in $frames) {
    $dim = if ($f.Size -ge 256) { [byte]0 } else { [byte]$f.Size }   # 0 means 256
    $w.Write($dim)               # width
    $w.Write($dim)               # height
    $w.Write([byte]0)            # colours in palette
    $w.Write([byte]0)            # reserved
    $w.Write([uint16]1)          # colour planes
    $w.Write([uint16]32)         # bits per pixel
    $w.Write([uint32]$f.Bytes.Length)
    $w.Write([uint32]$offset)
    $offset += $f.Bytes.Length
}
foreach ($f in $frames) { $w.Write($f.Bytes) }
$w.Flush()

$dir = Split-Path -Parent $OutputPath
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
[System.IO.File]::WriteAllBytes($OutputPath, $out.ToArray())
"Wrote $OutputPath ($($out.Length) bytes, frames: $($Sizes -join ', '))"
