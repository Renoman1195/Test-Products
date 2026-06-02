param(
    [switch]$Preview,
    [switch]$Clean,
    [int]$OlderThanDays = 1,
    [switch]$IncludeRecycleBin,
    [switch]$IncludeBrowserCache,
    [switch]$IncludeOldLogs,
    [switch]$IncludeUpdateLeftovers,
    [switch]$IncludeAppLeftovers,
    [switch]$IncludeBrowserData,
    [switch]$AnalyzeDownloads,
    [switch]$FindDuplicates
)

$ErrorActionPreference = "Continue"

if (-not $Preview -and -not $Clean) {
    $Preview = $true
}

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$LocalDataRoot = Join-Path ([Environment]::GetFolderPath("LocalApplicationData")) "TraceWear\RazorWear"
$LogDir = Join-Path $LocalDataRoot "logs"
New-Item -ItemType Directory -Path $LogDir -Force | Out-Null

$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$LogPath = Join-Path $LogDir "RazorWear-$Timestamp.log"
$Cutoff = (Get-Date).AddDays(-1 * $OlderThanDays)
$Now = Get-Date

function Write-Log {
    param([string]$Message)
    $line = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
    [Console]::Out.WriteLine($line)
    Add-Content -Path $LogPath -Value $line
}

function Format-Bytes {
    param([double]$Bytes)
    if ($Bytes -ge 1GB) { return "{0:N2} GB" -f ($Bytes / 1GB) }
    if ($Bytes -ge 1MB) { return "{0:N2} MB" -f ($Bytes / 1MB) }
    if ($Bytes -ge 1KB) { return "{0:N2} KB" -f ($Bytes / 1KB) }
    return "{0:N0} B" -f $Bytes
}

function Add-IfValue {
    param(
        [System.Collections.Generic.List[string]]$List,
        [string]$Path
    )

    if (-not [string]::IsNullOrWhiteSpace($Path)) {
        $List.Add($Path)
    }
}

function Join-IfBase {
    param(
        [string]$Base,
        [string]$Child
    )

    if ([string]::IsNullOrWhiteSpace($Base)) {
        return $null
    }

    return Join-Path $Base $Child
}

function Resolve-CleanupPath {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return @()
    }

    try {
        return @(Resolve-Path -Path $Path -ErrorAction SilentlyContinue | ForEach-Object {
            [System.IO.Path]::GetFullPath($_.Path).TrimEnd('\')
        })
    }
    catch {
        Write-Log "Could not resolve $Path : $($_.Exception.Message)"
        return @()
    }
}

function Test-PathUnderRoot {
    param(
        [string]$Path,
        [string[]]$Roots
    )

    try {
        $Resolved = [System.IO.Path]::GetFullPath($Path).TrimEnd('\')
    }
    catch {
        return $false
    }

    foreach ($Root in $Roots) {
        if ([string]::IsNullOrWhiteSpace($Root)) {
            continue
        }

        $CleanRoot = [System.IO.Path]::GetFullPath($Root).TrimEnd('\')
        if ($Resolved.Equals($CleanRoot, [System.StringComparison]::OrdinalIgnoreCase) -or
            $Resolved.StartsWith("$CleanRoot\", [System.StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }

    return $false
}

function Get-FilesFromPaths {
    param(
        [string[]]$Paths,
        [datetime]$Before,
        [string[]]$NamePatterns = @("*"),
        [scriptblock]$ExtraFilter = $null
    )

    $AllFiles = New-Object System.Collections.Generic.List[System.IO.FileInfo]

    foreach ($Path in $Paths) {
        if (-not (Test-Path -LiteralPath $Path)) {
            continue
        }

        try {
            $Files = Get-ChildItem -LiteralPath $Path -Recurse -Force -File -ErrorAction SilentlyContinue |
                Where-Object { $_.LastWriteTime -lt $Before }

            if ($NamePatterns.Count -gt 0 -and -not ($NamePatterns.Count -eq 1 -and $NamePatterns[0] -eq "*")) {
                $Files = $Files | Where-Object {
                    $FileName = $_.Name
                    foreach ($Pattern in $NamePatterns) {
                        if ($FileName -like $Pattern) { return $true }
                    }
                    return $false
                }
            }

            if ($null -ne $ExtraFilter) {
                $Files = $Files | Where-Object $ExtraFilter
            }

            foreach ($File in @($Files)) {
                $AllFiles.Add($File)
            }
        }
        catch {
            Write-Log "Could not scan $Path : $($_.Exception.Message)"
        }
    }

    return @($AllFiles)
}

function Get-BrowserCachePaths {
    $Paths = New-Object System.Collections.Generic.List[string]

    $Local = $env:LOCALAPPDATA
    $Roaming = $env:APPDATA
    $BrowserProfileRoots = @(
        Join-IfBase $Local "Google\Chrome\User Data\*",
        Join-IfBase $Local "Microsoft\Edge\User Data\*",
        Join-IfBase $Local "BraveSoftware\Brave-Browser\User Data\*"
    )

    foreach ($Root in $BrowserProfileRoots) {
        Add-IfValue $Paths (Join-IfBase $Root "Cache")
        Add-IfValue $Paths (Join-IfBase $Root "Code Cache")
        Add-IfValue $Paths (Join-IfBase $Root "GPUCache")
        Add-IfValue $Paths (Join-IfBase $Root "Service Worker\CacheStorage")
    }

    Add-IfValue $Paths (Join-IfBase $Roaming "Mozilla\Firefox\Profiles\*\cache2")

    return @($Paths | ForEach-Object { Resolve-CleanupPath $_ } | Select-Object -Unique)
}

function Get-BrowserDataFiles {
    $Patterns = New-Object System.Collections.Generic.List[string]
    $Local = $env:LOCALAPPDATA
    $Roaming = $env:APPDATA

    foreach ($Root in @(
        Join-IfBase $Local "Google\Chrome\User Data\*",
        Join-IfBase $Local "Microsoft\Edge\User Data\*",
        Join-IfBase $Local "BraveSoftware\Brave-Browser\User Data\*"
    )) {
        Add-IfValue $Patterns (Join-IfBase $Root "History")
        Add-IfValue $Patterns (Join-IfBase $Root "Cookies")
        Add-IfValue $Patterns (Join-IfBase $Root "Network\Cookies")
        Add-IfValue $Patterns (Join-IfBase $Root "Visited Links")
    }

    Add-IfValue $Patterns (Join-IfBase $Roaming "Mozilla\Firefox\Profiles\*\places.sqlite")
    Add-IfValue $Patterns (Join-IfBase $Roaming "Mozilla\Firefox\Profiles\*\cookies.sqlite")

    return @($Patterns | ForEach-Object { Resolve-CleanupPath $_ } | Select-Object -Unique | ForEach-Object {
        Get-Item -LiteralPath $_ -Force -ErrorAction SilentlyContinue
    } | Where-Object { $_ -is [System.IO.FileInfo] })
}

function Get-OldLogPaths {
    $Paths = New-Object System.Collections.Generic.List[string]
    Add-IfValue $Paths ([System.IO.Path]::GetTempPath())
    Add-IfValue $Paths (Join-IfBase $env:WINDIR "Temp")
    Add-IfValue $Paths (Join-IfBase $env:WINDIR "Logs")
    Add-IfValue $Paths (Join-IfBase $env:WINDIR "Panther")
    Add-IfValue $Paths (Join-IfBase $env:PROGRAMDATA "Microsoft\Windows\WER")
    Add-IfValue $Paths (Join-IfBase $env:LOCALAPPDATA "CrashDumps")
    return @($Paths | ForEach-Object { Resolve-CleanupPath $_ } | Select-Object -Unique)
}

function Get-UpdateLeftoverPaths {
    $Paths = New-Object System.Collections.Generic.List[string]
    Add-IfValue $Paths (Join-IfBase $env:WINDIR "SoftwareDistribution\Download")
    Add-IfValue $Paths (Join-IfBase $env:PROGRAMDATA "Microsoft\Windows\DeliveryOptimization\Cache")
    return @($Paths | ForEach-Object { Resolve-CleanupPath $_ } | Select-Object -Unique)
}

function Get-AppLeftoverPaths {
    $Roots = @(
        [System.IO.Path]::GetTempPath(),
        (Join-IfBase $env:WINDIR "Temp")
    ) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | ForEach-Object { Resolve-CleanupPath $_ }

    $Folders = New-Object System.Collections.Generic.List[string]
    foreach ($Root in $Roots) {
        try {
            Get-ChildItem -LiteralPath $Root -Force -Directory -ErrorAction SilentlyContinue |
                Where-Object {
                    $_.LastWriteTime -lt $Cutoff -and
                    ($_.Name -like "*setup*" -or $_.Name -like "*install*" -or $_.Name -like "is-*" -or $_.Name -like "*msi*" -or $_.Name -like "*nsis*")
                } |
                ForEach-Object { $Folders.Add($_.FullName) }
        }
        catch {
            Write-Log "Could not scan app leftovers in $Root : $($_.Exception.Message)"
        }
    }

    return @($Folders | Select-Object -Unique)
}

function Get-DownloadsPath {
    $UserProfilePath = [Environment]::GetFolderPath("UserProfile")
    if ([string]::IsNullOrWhiteSpace($UserProfilePath)) {
        return $null
    }

    return Join-Path $UserProfilePath "Downloads"
}

function Get-DownloadsClutter {
    param([datetime]$Before)

    $Downloads = Get-DownloadsPath
    if ([string]::IsNullOrWhiteSpace($Downloads) -or -not (Test-Path -LiteralPath $Downloads)) {
        return @()
    }

    try {
        return @(Get-ChildItem -LiteralPath $Downloads -Recurse -Force -File -ErrorAction SilentlyContinue |
            Where-Object { $_.LastWriteTime -lt $Before -or $_.Length -ge 500MB })
    }
    catch {
        Write-Log "Could not scan Downloads clutter: $($_.Exception.Message)"
        return @()
    }
}

function Get-DuplicateFiles {
    $Downloads = Get-DownloadsPath
    if ([string]::IsNullOrWhiteSpace($Downloads) -or -not (Test-Path -LiteralPath $Downloads)) {
        return @()
    }

    try {
        $Candidates = Get-ChildItem -LiteralPath $Downloads -Recurse -Force -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Length -gt 0 } |
            Group-Object Length |
            Where-Object { $_.Count -gt 1 }

        $Duplicates = @()
        foreach ($SizeGroup in $Candidates) {
            $HashGroups = @($SizeGroup.Group | ForEach-Object {
                try {
                    [pscustomobject]@{
                        Hash = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256 -ErrorAction Stop).Hash
                        File = $_
                    }
                }
                catch {
                    Write-Log "Could not hash $($_.FullName): $($_.Exception.Message)"
                }
            } | Group-Object Hash | Where-Object { $_.Count -gt 1 })

            foreach ($HashGroup in $HashGroups) {
                $Duplicates += [pscustomobject]@{
                    Hash = $HashGroup.Name
                    Files = @($HashGroup.Group | ForEach-Object { $_.File })
                }
            }
        }

        return @($Duplicates)
    }
    catch {
        Write-Log "Could not scan duplicate files: $($_.Exception.Message)"
        return @()
    }
}

function Remove-CleanableFile {
    param(
        [System.IO.FileInfo]$File,
        [string[]]$AllowedRoots
    )

    if (-not (Test-PathUnderRoot -Path $File.FullName -Roots $AllowedRoots)) {
        Write-Log "Skipped file outside approved cleanup roots: $($File.FullName)"
        return $false
    }

    try {
        Remove-Item -LiteralPath $File.FullName -Force -ErrorAction Stop
        return $true
    }
    catch {
        Write-Log "Skipped locked or protected file: $($File.FullName)"
        return $false
    }
}

function Remove-EmptyFolders {
    param([string[]]$Roots)

    foreach ($Root in $Roots) {
        if (-not (Test-Path -LiteralPath $Root)) {
            continue
        }

        try {
            Get-ChildItem -LiteralPath $Root -Recurse -Force -Directory -ErrorAction SilentlyContinue |
                Sort-Object FullName -Descending |
                ForEach-Object {
                    try {
                        if (-not (Get-ChildItem -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue)) {
                            Remove-Item -LiteralPath $_.FullName -Force -ErrorAction Stop
                        }
                    }
                    catch {
                        Write-Log "Skipped non-empty or protected folder: $($_.FullName)"
                    }
                }
        }
        catch {
            Write-Log "Could not remove empty folders under $Root : $($_.Exception.Message)"
        }
    }
}

function Get-FileStats {
    param([System.IO.FileInfo[]]$Files)

    $Bytes = ($Files | Measure-Object -Property Length -Sum).Sum
    if ($null -eq $Bytes) { $Bytes = 0 }

    return [pscustomobject]@{
        Count = @($Files).Count
        Bytes = [double]$Bytes
    }
}

function Invoke-CleanupTarget {
    param(
        [string]$Name,
        [System.IO.FileInfo[]]$Files,
        [string[]]$AllowedRoots,
        [bool]$ReportOnly = $false
    )

    Write-Log ""
    Write-Log "Scanning: $Name"

    $Stats = Get-FileStats -Files $Files
    Write-Log "Found $($Stats.Count) file(s), $(Format-Bytes $Stats.Bytes)."

    if ($ReportOnly) {
        Write-Log "Report-only: RazorWear will not delete this category automatically."
        return [pscustomobject]@{
            TotalFiles = $Stats.Count
            TotalBytes = $Stats.Bytes
            RemovedFiles = 0
            RemovedBytes = 0
        }
    }

    $RemovedFiles = 0
    $RemovedBytes = 0
    if ($Clean -and $Stats.Count -gt 0) {
        foreach ($File in $Files) {
            $Length = $File.Length
            if (Remove-CleanableFile -File $File -AllowedRoots $AllowedRoots) {
                $RemovedFiles += 1
                $RemovedBytes += $Length
            }
        }

        Remove-EmptyFolders -Roots $AllowedRoots
    }

    return [pscustomobject]@{
        TotalFiles = $Stats.Count
        TotalBytes = $Stats.Bytes
        RemovedFiles = $RemovedFiles
        RemovedBytes = $RemovedBytes
    }
}

function Get-RecycleBinStats {
    try {
        $Shell = New-Object -ComObject Shell.Application
        $RecycleBin = $Shell.Namespace(0xA)
        if ($null -eq $RecycleBin) {
            return [pscustomobject]@{ Count = 0; Bytes = 0 }
        }

        $Count = 0
        $Bytes = 0
        foreach ($Item in @($RecycleBin.Items())) {
            $Count += 1
            try {
                $Size = $Item.ExtendedProperty("Size")
                if ($null -ne $Size) {
                    $Bytes += [double]$Size
                }
            }
            catch {}
        }

        return [pscustomobject]@{ Count = $Count; Bytes = $Bytes }
    }
    catch {
        Write-Log "Could not inspect Recycle Bin: $($_.Exception.Message)"
        return [pscustomobject]@{ Count = 0; Bytes = 0 }
    }
}

Write-Log "RazorWear started."
Write-Log "Mode: $(if ($Clean) { 'Clean' } else { 'Preview' })"
Write-Log "Cleaning files older than $OlderThanDays day(s)."
Write-Log "Log file: $LogPath"
Write-Log "Selected categories: Temp files$(if ($IncludeBrowserCache) { ', Browser cache' })$(if ($IncludeOldLogs) { ', Old logs' })$(if ($IncludeUpdateLeftovers) { ', Update leftovers' })$(if ($IncludeAppLeftovers) { ', App leftovers' })$(if ($IncludeBrowserData) { ', Browser cookies/history' })$(if ($IncludeRecycleBin) { ', Recycle Bin' })$(if ($AnalyzeDownloads) { ', Downloads report' })$(if ($FindDuplicates) { ', Duplicate report' })"

$GrandTotalBytes = 0
$GrandTotalFiles = 0
$GrandRemovedBytes = 0
$GrandRemovedFiles = 0

function Add-TargetResult {
    param([object]$Result)

    $script:GrandTotalFiles += $Result.TotalFiles
    $script:GrandTotalBytes += $Result.TotalBytes
    $script:GrandRemovedFiles += $Result.RemovedFiles
    $script:GrandRemovedBytes += $Result.RemovedBytes
}

$TempPaths = @(
    [System.IO.Path]::GetTempPath(),
    (Join-IfBase $env:WINDIR "Temp")
) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | ForEach-Object { Resolve-CleanupPath $_ } | Select-Object -Unique
$TempFiles = Get-FilesFromPaths -Paths $TempPaths -Before $Cutoff
Add-TargetResult (Invoke-CleanupTarget -Name "Temp files: user temp and Windows temp" -Files $TempFiles -AllowedRoots $TempPaths)

if ($IncludeBrowserCache) {
    $BrowserCachePaths = Get-BrowserCachePaths
    $BrowserCacheFiles = Get-FilesFromPaths -Paths $BrowserCachePaths -Before $Cutoff
    Add-TargetResult (Invoke-CleanupTarget -Name "Browser cache: Chrome, Edge, Brave, Firefox cache folders" -Files $BrowserCacheFiles -AllowedRoots $BrowserCachePaths)
}

if ($IncludeOldLogs) {
    $OldLogPaths = Get-OldLogPaths
    $OldLogFiles = Get-FilesFromPaths -Paths $OldLogPaths -Before $Cutoff -NamePatterns @("*.log", "*.dmp", "*.mdmp", "*.etl")
    Add-TargetResult (Invoke-CleanupTarget -Name "Old logs and crash dumps" -Files $OldLogFiles -AllowedRoots $OldLogPaths)
}

if ($IncludeUpdateLeftovers) {
    $UpdatePaths = Get-UpdateLeftoverPaths
    $UpdateFiles = Get-FilesFromPaths -Paths $UpdatePaths -Before $Cutoff
    Add-TargetResult (Invoke-CleanupTarget -Name "Windows Update and Delivery Optimization leftovers" -Files $UpdateFiles -AllowedRoots $UpdatePaths)
}

if ($IncludeAppLeftovers) {
    $AppLeftoverPaths = Get-AppLeftoverPaths
    $AppLeftoverFiles = Get-FilesFromPaths -Paths $AppLeftoverPaths -Before $Cutoff
    Add-TargetResult (Invoke-CleanupTarget -Name "App leftovers: old installer-looking folders in temp locations" -Files $AppLeftoverFiles -AllowedRoots $AppLeftoverPaths)
}

if ($IncludeBrowserData) {
    $BrowserDataFiles = Get-BrowserDataFiles
    $BrowserDataRoots = @($BrowserDataFiles | ForEach-Object { Split-Path -Parent $_.FullName } | Select-Object -Unique)
    Add-TargetResult (Invoke-CleanupTarget -Name "Browser cookies and history: user-selected" -Files $BrowserDataFiles -AllowedRoots $BrowserDataRoots)
}

$RecycleStats = Get-RecycleBinStats
Write-Log ""
Write-Log "Recycle Bin report: $($RecycleStats.Count) item(s), $(Format-Bytes $RecycleStats.Bytes)."
if ($IncludeRecycleBin) {
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
        Write-Log "Preview mode will not clear the Recycle Bin."
    }
}
else {
    Write-Log "Recycle Bin is report-only unless selected."
}

if ($AnalyzeDownloads) {
    $DownloadFiles = Get-DownloadsClutter -Before $Cutoff
    $DownloadStats = Get-FileStats -Files $DownloadFiles
    Write-Log ""
    Write-Log "Downloads clutter report: $($DownloadStats.Count) large or old file(s), $(Format-Bytes $DownloadStats.Bytes)."
    Write-Log "Report-only: Downloads are never auto-deleted."
    foreach ($File in @($DownloadFiles | Sort-Object Length -Descending | Select-Object -First 10)) {
        Write-Log "Download candidate: $(Format-Bytes $File.Length) - $($File.FullName)"
    }
}

if ($FindDuplicates) {
    Write-Log ""
    Write-Log "Duplicate file report: scanning Downloads for same-size, same-hash files."
    $DuplicateGroups = Get-DuplicateFiles
    if (@($DuplicateGroups).Count -eq 0) {
        Write-Log "Duplicate file report: no duplicates found."
    }
    else {
        foreach ($Group in $DuplicateGroups) {
            Write-Log "Duplicate group hash $($Group.Hash):"
            foreach ($File in $Group.Files) {
                Write-Log "  $(Format-Bytes $File.Length) - $($File.FullName)"
            }
        }
        Write-Log "Report-only: duplicate files require user confirmation outside automatic cleanup."
    }
}

Write-Log ""
if ($Clean) {
    Write-Log "Removed $GrandRemovedFiles file(s), approximately $(Format-Bytes $GrandRemovedBytes)."
    Write-Log "Report-only categories may show extra cleanup opportunities but were not auto-deleted."
}
else {
    Write-Log "Preview total cleanable: $GrandTotalFiles file(s), approximately $(Format-Bytes $GrandTotalBytes)."
    Write-Log "Run clean mode to remove selected cleanable categories. Downloads and duplicates remain report-only."
}
Write-Log "RazorWear finished."
