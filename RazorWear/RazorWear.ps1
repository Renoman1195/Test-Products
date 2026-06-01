param(
    [switch]$Preview,
    [switch]$Clean,
    [int]$OlderThanDays = 1,
    [switch]$IncludeRecycleBin
)

$ErrorActionPreference = "Continue"

if (-not $Preview -and -not $Clean) {
    $Preview = $true
}

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogDir = Join-Path $ProjectRoot "logs"
New-Item -ItemType Directory -Path $LogDir -Force | Out-Null

$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$LogPath = Join-Path $LogDir "RazorWear-$Timestamp.log"
$Cutoff = (Get-Date).AddDays(-1 * $OlderThanDays)

function Write-Log {
    param([string]$Message)
    $line = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
    Write-Host $line
    Add-Content -Path $LogPath -Value $line
}

function Format-Bytes {
    param([double]$Bytes)
    if ($Bytes -ge 1GB) { return "{0:N2} GB" -f ($Bytes / 1GB) }
    if ($Bytes -ge 1MB) { return "{0:N2} MB" -f ($Bytes / 1MB) }
    if ($Bytes -ge 1KB) { return "{0:N2} KB" -f ($Bytes / 1KB) }
    return "{0:N0} B" -f $Bytes
}

function Get-CleanableFiles {
    param(
        [string]$Path,
        [datetime]$Before
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return @()
    }

    try {
        return @(Get-ChildItem -LiteralPath $Path -Recurse -Force -File -ErrorAction SilentlyContinue |
            Where-Object { $_.LastWriteTime -lt $Before })
    }
    catch {
        Write-Log "Could not scan $Path : $($_.Exception.Message)"
        return @()
    }
}

function Remove-CleanableFile {
    param([System.IO.FileInfo]$File)

    try {
        Remove-Item -LiteralPath $File.FullName -Force -ErrorAction Stop
        return $true
    }
    catch {
        Write-Log "Skipped locked or protected file: $($File.FullName)"
        return $false
    }
}

function Test-SafeCleanupPath {
    param([string]$Path)

    $Resolved = [System.IO.Path]::GetFullPath($Path).TrimEnd('\')
    $AllowedRoots = @(
        [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath()).TrimEnd('\'),
        [System.IO.Path]::GetFullPath((Join-Path $env:WINDIR "Temp")).TrimEnd('\')
    )

    foreach ($Root in $AllowedRoots) {
        if ($Resolved.Equals($Root, [System.StringComparison]::OrdinalIgnoreCase) -or
            $Resolved.StartsWith("$Root\", [System.StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }

    return $false
}

$Targets = @(
    @{
        Name = "User temp files"
        Path = [System.IO.Path]::GetTempPath()
    },
    @{
        Name = "Windows temp files"
        Path = Join-Path $env:WINDIR "Temp"
    }
)

Write-Log "RazorWear started."
Write-Log "Mode: $(if ($Clean) { 'Clean' } else { 'Preview' })"
Write-Log "Cleaning files older than $OlderThanDays day(s)."
Write-Log "Log file: $LogPath"

$GrandTotalBytes = 0
$GrandTotalFiles = 0
$GrandRemovedBytes = 0
$GrandRemovedFiles = 0

foreach ($Target in $Targets) {
    Write-Log ""
    Write-Log "Scanning: $($Target.Name) - $($Target.Path)"

    if (-not (Test-SafeCleanupPath -Path $Target.Path)) {
        Write-Log "Skipped unsafe cleanup path: $($Target.Path)"
        continue
    }

    $Files = Get-CleanableFiles -Path $Target.Path -Before $Cutoff
    $TotalBytes = ($Files | Measure-Object -Property Length -Sum).Sum
    if ($null -eq $TotalBytes) { $TotalBytes = 0 }

    $GrandTotalFiles += $Files.Count
    $GrandTotalBytes += $TotalBytes

    Write-Log "Found $($Files.Count) file(s), $(Format-Bytes $TotalBytes)."

    if ($Clean -and $Files.Count -gt 0) {
        foreach ($File in $Files) {
            if (Remove-CleanableFile -File $File) {
                $GrandRemovedFiles += 1
                $GrandRemovedBytes += $File.Length
            }
        }
    }
}

if ($IncludeRecycleBin) {
    Write-Log ""
    Write-Log "Recycle Bin: included."
    if ($Clean) {
        try {
            Clear-RecycleBin -Force -ErrorAction Stop
            Write-Log "Recycle Bin cleared."
        }
        catch {
            Write-Log "Could not clear Recycle Bin: $($_.Exception.Message)"
        }
    }
    else {
        Write-Log "Preview mode does not calculate Recycle Bin size."
    }
}
else {
    Write-Log ""
    Write-Log "Recycle Bin: skipped. Use -IncludeRecycleBin only if you intentionally want it cleared."
}

Write-Log ""
if ($Clean) {
    Write-Log "Removed $GrandRemovedFiles file(s), approximately $(Format-Bytes $GrandRemovedBytes)."
}
else {
    Write-Log "Preview total: $GrandTotalFiles file(s), approximately $(Format-Bytes $GrandTotalBytes)."
    Write-Log "Run Run-Clean.bat to remove these temporary files."
}
Write-Log "RazorWear finished."
