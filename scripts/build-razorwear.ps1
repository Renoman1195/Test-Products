param(
    [string]$Configuration = "Release"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$appRoot = Join-Path $repoRoot "RazorWear"
$sourcePath = Join-Path $appRoot "src\RazorWear.cs"
$distDir = Join-Path $appRoot "dist"
$outputPath = Join-Path $distDir "RazorWear.exe"

function Get-CSharpCompiler {
    $candidates = @(
        "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe",
        "C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe"
    )

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate) {
            return $candidate
        }
    }

    throw "C# compiler not found. Install Visual Studio, .NET SDK, or .NET Framework build tools."
}

if (-not (Test-Path -LiteralPath $sourcePath)) {
    throw "Missing launcher source: $sourcePath"
}

New-Item -ItemType Directory -Force -Path $distDir | Out-Null

$compiler = Get-CSharpCompiler
$optimize = if ($Configuration -eq "Debug") { "/optimize-" } else { "/optimize+" }
$arguments = @(
    "/nologo",
    "/target:winexe",
    "/platform:x64",
    $optimize,
    "/out:$outputPath",
    "/reference:System.dll",
    "/reference:System.Drawing.dll",
    "/reference:System.Windows.Forms.dll",
    $sourcePath
)

Write-Host "Building RazorWear launcher"
Write-Host "Compiler: $compiler"
Write-Host "Output: $outputPath"

& $compiler @arguments
if ($LASTEXITCODE -ne 0) {
    throw "RazorWear launcher build failed with exit code $LASTEXITCODE."
}

$hash = Get-FileHash -Algorithm SHA256 -LiteralPath $outputPath
[ordered]@{
    Output = $outputPath
    SizeBytes = (Get-Item -LiteralPath $outputPath).Length
    Sha256 = $hash.Hash
} | ConvertTo-Json
