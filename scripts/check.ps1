Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$appRoot = Join-Path $repoRoot "RazorWear"

Write-Host "RazorWear verification"
Write-Host "Repo: $repoRoot"

if (-not (Test-Path -LiteralPath $appRoot)) {
    throw "Missing RazorWear app folder: $appRoot"
}

Write-Host "Checking PowerShell syntax..."
$powerShellFiles = Get-ChildItem -Path $repoRoot -Recurse -Filter "*.ps1" -File
foreach ($file in $powerShellFiles) {
    $errors = $null
    $tokens = $null
    [System.Management.Automation.Language.Parser]::ParseFile(
        $file.FullName,
        [ref]$tokens,
        [ref]$errors
    ) | Out-Null

    if ($errors) {
        Write-Host "Parse failed: $($file.FullName)"
        $errors | Format-List
        throw "PowerShell parse failed for $($file.Name)"
    }

    Write-Host "Parse ok: $($file.FullName.Substring($repoRoot.Length + 1))"
}

Write-Host "Checking launchers..."
$requiredFiles = @(
    "RazorWear.ps1",
    "RazorWear-GUI.ps1",
    "Run-RazorWear.bat",
    "Run-Preview.bat",
    "Run-Clean.bat",
    "Run-Clean-With-Recycle-Bin.bat",
    "README.md",
    "PRIVACY.md",
    "SAFETY.md",
    "StoreSubmission\PackagingChecklist.md",
    "StoreSubmission\Package.appxmanifest.template.xml"
)

foreach ($relativePath in $requiredFiles) {
    $path = Join-Path $appRoot $relativePath
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Missing required file: $relativePath"
    }
}

$batchChecks = @{
    "Run-RazorWear.bat" = "RazorWear-GUI.ps1"
    "Run-Preview.bat" = "RazorWear.ps1"
    "Run-Clean.bat" = "RazorWear.ps1"
    "Run-Clean-With-Recycle-Bin.bat" = "RazorWear.ps1"
}

foreach ($batchName in $batchChecks.Keys) {
    $batchPath = Join-Path $appRoot $batchName
    $expectedScript = $batchChecks[$batchName]
    $batchText = Get-Content -LiteralPath $batchPath -Raw
    if ($batchText -notmatch [regex]::Escape($expectedScript)) {
        throw "$batchName does not reference $expectedScript"
    }
}

Write-Host "Running safe preview scan..."
$previewOutput = & powershell.exe -NoProfile -ExecutionPolicy Bypass `
    -File (Join-Path $appRoot "RazorWear.ps1") `
    -Preview `
    -OlderThanDays 30

$previewText = $previewOutput -join [Environment]::NewLine
if ($previewText -notmatch "Mode: Preview") {
    throw "Preview output did not report preview mode."
}
if ($previewText -notmatch "RazorWear finished") {
    throw "Preview output did not finish cleanly."
}
if ($previewText -match "Removed \d+ file") {
    throw "Preview mode reported removal, which should never happen."
}

Write-Host "Building native launcher..."
& (Join-Path $repoRoot "scripts\build-razorwear.ps1") | Out-Host
$exePath = Join-Path $appRoot "dist\RazorWear.exe"
if (-not (Test-Path -LiteralPath $exePath)) {
    throw "Native launcher was not built: $exePath"
}

Write-Host "Running native launcher preview scan..."
$localLogDir = Join-Path $env:LOCALAPPDATA "TraceWear\RazorWear\logs"
$beforeNativeRun = Get-Date
& $exePath --preview --older-than-days 30 | Out-Null
$latestNativeLog = Get-ChildItem -LiteralPath $localLogDir -Filter "RazorWear-*.log" -File -ErrorAction Stop |
    Where-Object { $_.LastWriteTime -ge $beforeNativeRun.AddSeconds(-2) } |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1
if (-not $latestNativeLog) {
    throw "Native launcher did not write a fresh preview log under $localLogDir."
}
$exeText = Get-Content -LiteralPath $latestNativeLog.FullName -Raw
if ($exeText -notmatch "Mode: Preview") {
    throw "Native launcher preview output did not report preview mode."
}
if ($exeText -notmatch "RazorWear finished") {
    throw "Native launcher preview output did not finish cleanly."
}
if ($exeText -match "Removed \d+ file") {
    throw "Native launcher preview mode reported removal, which should never happen."
}

Write-Host "Checking Store assets..."
$assetDir = Join-Path $appRoot "StoreSubmission\Assets"
$requiredAssets = @(
    "StoreLogo.png",
    "Square44x44Logo.png",
    "Square150x150Logo.png",
    "Wide310x150Logo.png"
)

foreach ($asset in $requiredAssets) {
    $path = Join-Path $assetDir $asset
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Missing Store asset: $asset"
    }
    if ((Get-Item -LiteralPath $path).Length -le 0) {
        throw "Store asset is empty: $asset"
    }
}

Write-Host "Verification complete."
