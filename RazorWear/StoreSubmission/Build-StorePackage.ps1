param(
    [string]$MakeAppxPath = "makeappx.exe",
    [string]$SignToolPath = "signtool.exe",
    [string]$CertificateThumbprint = "",
    [switch]$Sign,
    [string]$Configuration = "Store"
)

$ErrorActionPreference = "Stop"

$StoreRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$AppRoot = Split-Path -Parent $StoreRoot
$RepoRoot = Split-Path -Parent $AppRoot
$BuildRoot = Join-Path $StoreRoot "PackageBuild"
$LayoutRoot = Join-Path $BuildRoot "RazorWear"
$PackageRoot = Join-Path $StoreRoot "Packages"
$PackagePath = Join-Path $PackageRoot "RazorWear-0.5.2.0.msix"
$DistExe = Join-Path $AppRoot "dist\RazorWear.exe"

if (Test-Path -LiteralPath $BuildRoot) {
    Remove-Item -LiteralPath $BuildRoot -Recurse -Force
}

New-Item -ItemType Directory -Path $LayoutRoot -Force | Out-Null
New-Item -ItemType Directory -Path $PackageRoot -Force | Out-Null

if (-not (Test-Path -LiteralPath $DistExe)) {
    powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $RepoRoot "scripts\build-razorwear.ps1")
}

$requiredFiles = @(
    "RazorWear-GUI.ps1",
    "RazorWear.ps1",
    "VERSION.txt",
    "PRIVACY.md",
    "SAFETY.md"
)

foreach ($file in $requiredFiles) {
    $source = Join-Path $AppRoot $file
    if (-not (Test-Path -LiteralPath $source)) {
        throw "Missing required package file: $source"
    }
    Copy-Item -LiteralPath $source -Destination (Join-Path $LayoutRoot $file) -Force
}

if (-not (Test-Path -LiteralPath $DistExe)) {
    throw "Missing built launcher: $DistExe"
}
Copy-Item -LiteralPath $DistExe -Destination (Join-Path $LayoutRoot "RazorWear.exe") -Force

Copy-Item -LiteralPath (Join-Path $StoreRoot "Package.appxmanifest.template.xml") -Destination (Join-Path $LayoutRoot "AppxManifest.xml") -Force
Copy-Item -LiteralPath (Join-Path $StoreRoot "Assets") -Destination (Join-Path $LayoutRoot "Assets") -Recurse -Force

if (Test-Path -LiteralPath $PackagePath) {
    Remove-Item -LiteralPath $PackagePath -Force
}

& $MakeAppxPath pack /d $LayoutRoot /p $PackagePath /o
if ($LASTEXITCODE -ne 0) {
    throw "makeappx failed with exit code $LASTEXITCODE"
}

Write-Host "Package created: $PackagePath"

if ($Sign) {
    if ([string]::IsNullOrWhiteSpace($CertificateThumbprint)) {
        throw "Use -CertificateThumbprint when -Sign is selected."
    }

    & $SignToolPath sign /fd SHA256 /sha1 $CertificateThumbprint $PackagePath
    if ($LASTEXITCODE -ne 0) {
        throw "signtool sign failed with exit code $LASTEXITCODE"
    }

    & $SignToolPath verify /pa /v $PackagePath
    if ($LASTEXITCODE -ne 0) {
        throw "signtool verify failed with exit code $LASTEXITCODE"
    }
}
else {
    Write-Host "This package is unsigned. Sign it with Partner Center identity before local install or final validation."
}
