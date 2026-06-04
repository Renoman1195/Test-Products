param(
    [string]$PackageName = "RazorWear.Dev",
    [string]$Publisher = "CN=RazorWearDev",
    [string]$PublisherDisplayName = "RazorWear Dev",
    [string]$Version = "0.5.2.0",
    [string]$OutputRoot = "target\msix"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$appRoot = Join-Path $repoRoot "RazorWear"
$distExe = Join-Path $appRoot "dist\RazorWear.exe"
$manifestTemplate = Join-Path $appRoot "StoreSubmission\Package.appxmanifest.template.xml"
$assetsDir = Join-Path $appRoot "StoreSubmission\Assets"
$outputRootPath = [System.IO.Path]::GetFullPath((Join-Path $repoRoot $OutputRoot))
$stageDir = Join-Path $outputRootPath "stage"
$packagePath = Join-Path $outputRootPath "RazorWear_$($Version)_x64.msix"

function Get-MakeAppx {
    $roots = @(
        "C:\Program Files (x86)\Windows Kits\10\bin",
        "C:\Program Files\Windows Kits\10\bin"
    )

    foreach ($root in $roots) {
        if (-not (Test-Path -LiteralPath $root)) {
            continue
        }

        $tool = Get-ChildItem -LiteralPath $root -Recurse -Filter makeappx.exe -File -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -match "\\x64\\makeappx.exe$" } |
            Sort-Object FullName -Descending |
            Select-Object -First 1

        if ($tool) {
            return $tool.FullName
        }
    }

    throw "MakeAppx.exe not found. Install the Windows SDK or MSIX Packaging Tool."
}

if (-not (Test-Path -LiteralPath $distExe)) {
    & (Join-Path $repoRoot "scripts\build-razorwear.ps1") | Out-Host
}

if (-not (Test-Path -LiteralPath $manifestTemplate)) {
    throw "Missing manifest template: $manifestTemplate"
}

if (Test-Path -LiteralPath $stageDir) {
    Remove-Item -LiteralPath $stageDir -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $stageDir | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $stageDir "Assets") | Out-Null

Copy-Item -LiteralPath $distExe -Destination (Join-Path $stageDir "RazorWear.exe") -Force
Copy-Item -LiteralPath (Join-Path $appRoot "RazorWear.ps1") -Destination $stageDir -Force
Copy-Item -LiteralPath (Join-Path $appRoot "RazorWear-GUI.ps1") -Destination $stageDir -Force
Copy-Item -LiteralPath (Join-Path $appRoot "VERSION.txt") -Destination $stageDir -Force
Copy-Item -LiteralPath (Join-Path $appRoot "PRIVACY.md") -Destination $stageDir -Force
Copy-Item -LiteralPath (Join-Path $appRoot "SAFETY.md") -Destination $stageDir -Force
Copy-Item -LiteralPath (Join-Path $appRoot "StoreSubmission\PrivacyPolicy.html") -Destination $stageDir -Force
Copy-Item -Path (Join-Path $assetsDir "*") -Destination (Join-Path $stageDir "Assets") -Force

$manifest = Get-Content -LiteralPath $manifestTemplate -Raw
$manifest = $manifest.Replace("REPLACE_WITH_PARTNER_CENTER_PACKAGE_NAME", $PackageName)
$manifest = $manifest.Replace("CN=REPLACE_WITH_PARTNER_CENTER_PUBLISHER", $Publisher)
$manifest = $manifest.Replace("REPLACE_WITH_PUBLISHER_DISPLAY_NAME", $PublisherDisplayName)
$manifest = $manifest.Replace('Version="0.5.2.0"', ('Version="' + $Version + '"'))
$manifest | Set-Content -Path (Join-Path $stageDir "AppxManifest.xml") -Encoding UTF8

$makeAppx = Get-MakeAppx
New-Item -ItemType Directory -Force -Path $outputRootPath | Out-Null
if (Test-Path -LiteralPath $packagePath) {
    Remove-Item -LiteralPath $packagePath -Force
}

Write-Host "Packaging RazorWear MSIX"
Write-Host "MakeAppx: $makeAppx"
Write-Host "Stage: $stageDir"
Write-Host "Package: $packagePath"

& $makeAppx pack /d $stageDir /p $packagePath /overwrite
if ($LASTEXITCODE -ne 0) {
    throw "MakeAppx failed with exit code $LASTEXITCODE."
}

$hash = Get-FileHash -Algorithm SHA256 -LiteralPath $packagePath
[ordered]@{
    Package = $packagePath
    SizeBytes = (Get-Item -LiteralPath $packagePath).Length
    Sha256 = $hash.Hash
    Signed = $false
    Note = "Development MSIX is unsigned. Use Partner Center identity and signing before submission."
} | ConvertTo-Json
