Add-Type -AssemblyName System.Drawing

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$AssetDir = Join-Path $Root "Assets"
New-Item -ItemType Directory -Path $AssetDir -Force | Out-Null

function New-RazorWearAsset {
    param(
        [string]$Path,
        [int]$Width,
        [int]$Height,
        [int]$FontSize
    )

    $bitmap = New-Object System.Drawing.Bitmap($Width, $Height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.Clear([System.Drawing.Color]::FromArgb(37, 84, 79))

    $accentBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(223, 244, 232))
    $whiteBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $font = New-Object System.Drawing.Font("Segoe UI", $FontSize, [System.Drawing.FontStyle]::Bold)

    $circleSize = [Math]::Min($Width, $Height) * 0.42
    $circleX = ($Width - $circleSize) / 2
    $circleY = ($Height - $circleSize) / 2 - ($Height * 0.08)
    $graphics.FillEllipse($accentBrush, $circleX, $circleY, $circleSize, $circleSize)

    $text = "RW"
    $textSize = $graphics.MeasureString($text, $font)
    $textX = ($Width - $textSize.Width) / 2
    $textY = $circleY + (($circleSize - $textSize.Height) / 2)
    $graphics.DrawString($text, $font, $whiteBrush, $textX, $textY)

    if ($Width -gt $Height) {
        $labelFont = New-Object System.Drawing.Font("Segoe UI", [Math]::Max(18, [int]($Height * 0.16)), [System.Drawing.FontStyle]::Bold)
        $label = "RazorWear"
        $labelSize = $graphics.MeasureString($label, $labelFont)
        $graphics.DrawString($label, $labelFont, $whiteBrush, ($Width - $labelSize.Width) / 2, $Height - $labelSize.Height - 18)
        $labelFont.Dispose()
    }

    $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose()
    $bitmap.Dispose()
    $accentBrush.Dispose()
    $whiteBrush.Dispose()
    $font.Dispose()
}

New-RazorWearAsset -Path (Join-Path $AssetDir "Square44x44Logo.png") -Width 44 -Height 44 -FontSize 10
New-RazorWearAsset -Path (Join-Path $AssetDir "Square150x150Logo.png") -Width 150 -Height 150 -FontSize 34
New-RazorWearAsset -Path (Join-Path $AssetDir "StoreLogo.png") -Width 50 -Height 50 -FontSize 12
New-RazorWearAsset -Path (Join-Path $AssetDir "Wide310x150Logo.png") -Width 310 -Height 150 -FontSize 32

Write-Host "Store assets generated in $AssetDir"
