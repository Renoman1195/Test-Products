Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = "Stop"

$AppRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$CleanerPath = Join-Path $AppRoot "RazorWear.ps1"
$VersionPath = Join-Path $AppRoot "VERSION.txt"
$VersionText = "preview"
if (Test-Path -LiteralPath $VersionPath) {
    $VersionText = ((Get-Content -LiteralPath $VersionPath -TotalCount 1) -replace "^RazorWear\s+", "").Trim()
}

function New-Font {
    param(
        [float]$Size,
        [System.Drawing.FontStyle]$Style = [System.Drawing.FontStyle]::Regular
    )

    return New-Object System.Drawing.Font("Segoe UI", $Size, $Style)
}

function Set-ButtonStyle {
    param(
        [System.Windows.Forms.Button]$Button,
        [System.Drawing.Color]$BackColor,
        [System.Drawing.Color]$ForeColor
    )

    $Button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $Button.FlatAppearance.BorderSize = 0
    $Button.BackColor = $BackColor
    $Button.ForeColor = $ForeColor
    $Button.Font = New-Font 10 ([System.Drawing.FontStyle]::Bold)
    $Button.Cursor = [System.Windows.Forms.Cursors]::Hand
}

$Ink = [System.Drawing.Color]::FromArgb(30, 43, 40)
$Muted = [System.Drawing.Color]::FromArgb(92, 104, 98)
$SoftMuted = [System.Drawing.Color]::FromArgb(116, 127, 121)
$Brand = [System.Drawing.Color]::FromArgb(31, 91, 84)
$BrandDark = [System.Drawing.Color]::FromArgb(20, 61, 58)
$Mint = [System.Drawing.Color]::FromArgb(218, 244, 232)
$Surface = [System.Drawing.Color]::FromArgb(252, 253, 252)
$Canvas = [System.Drawing.Color]::FromArgb(242, 246, 244)
$Warning = [System.Drawing.Color]::FromArgb(191, 123, 54)
$Success = [System.Drawing.Color]::FromArgb(36, 125, 87)
$SuccessBack = [System.Drawing.Color]::FromArgb(220, 246, 233)

function Invoke-RazorWear {
    param(
        [string]$Mode,
        [int]$OlderThanDays,
        [bool]$IncludeRecycleBin,
        [bool]$IncludeBrowserCache,
        [bool]$IncludeOldLogs,
        [bool]$IncludeUpdateLeftovers,
        [bool]$IncludeAppLeftovers,
        [bool]$IncludeBrowserData,
        [bool]$AnalyzeDownloads,
        [bool]$FindDuplicates
    )

    $arguments = @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", "`"$CleanerPath`"",
        "-$Mode",
        "-OlderThanDays", $OlderThanDays
    )

    if ($IncludeRecycleBin) {
        $arguments += "-IncludeRecycleBin"
    }
    if ($IncludeBrowserCache) {
        $arguments += "-IncludeBrowserCache"
    }
    if ($IncludeOldLogs) {
        $arguments += "-IncludeOldLogs"
    }
    if ($IncludeUpdateLeftovers) {
        $arguments += "-IncludeUpdateLeftovers"
    }
    if ($IncludeAppLeftovers) {
        $arguments += "-IncludeAppLeftovers"
    }
    if ($IncludeBrowserData) {
        $arguments += "-IncludeBrowserData"
    }
    if ($AnalyzeDownloads) {
        $arguments += "-AnalyzeDownloads"
    }
    if ($FindDuplicates) {
        $arguments += "-FindDuplicates"
    }

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo.FileName = "powershell.exe"
    $process.StartInfo.Arguments = ($arguments -join " ")
    $process.StartInfo.UseShellExecute = $false
    $process.StartInfo.RedirectStandardOutput = $true
    $process.StartInfo.RedirectStandardError = $true
    $process.StartInfo.CreateNoWindow = $true

    [void]$process.Start()
    $output = $process.StandardOutput.ReadToEnd()
    $errorOutput = $process.StandardError.ReadToEnd()
    $process.WaitForExit()

    if ($errorOutput.Trim().Length -gt 0) {
        return "$output`r`n$errorOutput".Trim()
    }

    return $output.Trim()
}

$Form = New-Object System.Windows.Forms.Form
$Form.Text = "RazorWear"
$Form.StartPosition = "CenterScreen"
$Form.Size = New-Object System.Drawing.Size(980, 760)
$Form.MinimumSize = New-Object System.Drawing.Size(940, 720)
$Form.BackColor = $Canvas
$Form.Font = New-Font 9

$Shell = New-Object System.Windows.Forms.TableLayoutPanel
$Shell.Dock = [System.Windows.Forms.DockStyle]::Fill
$Shell.ColumnCount = 1
$Shell.RowCount = 3
$Shell.Margin = New-Object System.Windows.Forms.Padding(0)
$Shell.Padding = New-Object System.Windows.Forms.Padding(0)
$Shell.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100)))
$Shell.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 26)))
$Shell.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 126)))
$Shell.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 100)))
$Form.Controls.Add($Shell)

$MenuStrip = New-Object System.Windows.Forms.MenuStrip
$MenuStrip.Dock = [System.Windows.Forms.DockStyle]::Fill
$MenuStrip.BackColor = [System.Drawing.Color]::FromArgb(249, 251, 250)
$MenuStrip.ForeColor = $Ink
$MenuStrip.Font = New-Font 9
$MenuStrip.RenderMode = [System.Windows.Forms.ToolStripRenderMode]::System
$Form.MainMenuStrip = $MenuStrip
$Shell.Controls.Add($MenuStrip, 0, 0)

$FileMenu = New-Object System.Windows.Forms.ToolStripMenuItem("File")
$ExitMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem("Exit")
$FileMenu.DropDownItems.Add($ExitMenuItem) | Out-Null
$MenuStrip.Items.Add($FileMenu) | Out-Null

$AboutMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem("About")
$MenuStrip.Items.Add($AboutMenuItem) | Out-Null

$ReportBugMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem("Report Bug")
$MenuStrip.Items.Add($ReportBugMenuItem) | Out-Null

$Header = New-Object System.Windows.Forms.Panel
$Header.Dock = [System.Windows.Forms.DockStyle]::Fill
$Header.Height = 126
$Header.BackColor = $BrandDark
$Shell.Controls.Add($Header, 0, 1)

$BrandMark = New-Object System.Windows.Forms.Label
$BrandMark.Text = "RW"
$BrandMark.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$BrandMark.Font = New-Font 18 ([System.Drawing.FontStyle]::Bold)
$BrandMark.ForeColor = $BrandDark
$BrandMark.BackColor = $Mint
$BrandMark.Size = New-Object System.Drawing.Size(64, 64)
$BrandMark.Location = New-Object System.Drawing.Point(30, 30)
$Header.Controls.Add($BrandMark)

$Title = New-Object System.Windows.Forms.Label
$Title.Text = "RazorWear"
$Title.AutoSize = $true
$Title.Font = New-Font 26 ([System.Drawing.FontStyle]::Bold)
$Title.ForeColor = [System.Drawing.Color]::White
$Title.Location = New-Object System.Drawing.Point(112, 26)
$Header.Controls.Add($Title)

$Subtitle = New-Object System.Windows.Forms.Label
$Subtitle.Text = "Private cleanup. No tracking. No accounts. No background service."
$Subtitle.AutoSize = $false
$Subtitle.Size = New-Object System.Drawing.Size(650, 36)
$Subtitle.Font = New-Font 11
$Subtitle.ForeColor = [System.Drawing.Color]::FromArgb(221, 239, 232)
$Subtitle.Location = New-Object System.Drawing.Point(116, 70)
$Subtitle.UseCompatibleTextRendering = $true
$Header.Controls.Add($Subtitle)
$Subtitle.BringToFront()

$PrivacyBadge = New-Object System.Windows.Forms.Label
$PrivacyBadge.Text = "Private by design"
$PrivacyBadge.AutoSize = $true
$PrivacyBadge.Font = New-Font 10 ([System.Drawing.FontStyle]::Bold)
$PrivacyBadge.ForeColor = $BrandDark
$PrivacyBadge.BackColor = $Mint
$PrivacyBadge.Padding = New-Object System.Windows.Forms.Padding(12, 6, 12, 6)
$PrivacyBadge.Location = New-Object System.Drawing.Point(760, 34)
$PrivacyBadge.Anchor = "Top, Right"
$Header.Controls.Add($PrivacyBadge)

$VersionBadge = New-Object System.Windows.Forms.Label
$VersionBadge.Text = $VersionText
$VersionBadge.AutoSize = $true
$VersionBadge.Font = New-Font 8
$VersionBadge.ForeColor = [System.Drawing.Color]::FromArgb(190, 214, 207)
$VersionBadge.Location = New-Object System.Drawing.Point(786, 72)
$VersionBadge.Anchor = "Top, Right"
$Header.Controls.Add($VersionBadge)

$Main = New-Object System.Windows.Forms.TableLayoutPanel
$Main.Dock = [System.Windows.Forms.DockStyle]::Fill
$Main.Padding = New-Object System.Windows.Forms.Padding(26)
$Main.ColumnCount = 2
$Main.RowCount = 1
$Main.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 306)))
$Main.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100)))
$Shell.Controls.Add($Main, 0, 2)

$ControlsPanel = New-Object System.Windows.Forms.Panel
$ControlsPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$ControlsPanel.BackColor = $Surface
$ControlsPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$ControlsPanel.Padding = New-Object System.Windows.Forms.Padding(18)
$ControlsPanel.AutoScroll = $true
$Main.Controls.Add($ControlsPanel, 0, 0)

$OptionsTitle = New-Object System.Windows.Forms.Label
$OptionsTitle.Text = "Clean without the creep."
$OptionsTitle.AutoSize = $true
$OptionsTitle.Font = New-Font 14 ([System.Drawing.FontStyle]::Bold)
$OptionsTitle.ForeColor = $Ink
$OptionsTitle.Location = New-Object System.Drawing.Point(20, 20)
$ControlsPanel.Controls.Add($OptionsTitle)

$OptionsText = New-Object System.Windows.Forms.Label
$OptionsText.Text = "RazorWear clears selected safe areas while leaving your personal files alone."
$OptionsText.Size = New-Object System.Drawing.Size(250, 54)
$OptionsText.Font = New-Font 9
$OptionsText.ForeColor = $Muted
$OptionsText.Location = New-Object System.Drawing.Point(22, 58)
$ControlsPanel.Controls.Add($OptionsText)

$AgeLabel = New-Object System.Windows.Forms.Label
$AgeLabel.Text = "Clean temp files older than"
$AgeLabel.AutoSize = $true
$AgeLabel.Font = New-Font 9 ([System.Drawing.FontStyle]::Bold)
$AgeLabel.ForeColor = $Ink
$AgeLabel.Location = New-Object System.Drawing.Point(22, 96)
$ControlsPanel.Controls.Add($AgeLabel)

$AgeInput = New-Object System.Windows.Forms.NumericUpDown
$AgeInput.Minimum = 1
$AgeInput.Maximum = 30
$AgeInput.Value = 1
$AgeInput.Width = 72
$AgeInput.Location = New-Object System.Drawing.Point(24, 124)
$AgeInput.Font = New-Font 11
$ControlsPanel.Controls.Add($AgeInput)

$DaysLabel = New-Object System.Windows.Forms.Label
$DaysLabel.Text = "day(s)"
$DaysLabel.AutoSize = $true
$DaysLabel.Font = New-Font 10
$DaysLabel.ForeColor = $Muted
$DaysLabel.Location = New-Object System.Drawing.Point(106, 128)
$ControlsPanel.Controls.Add($DaysLabel)

$CleanupOptionsLabel = New-Object System.Windows.Forms.Label
$CleanupOptionsLabel.Text = "Cleanup areas"
$CleanupOptionsLabel.AutoSize = $true
$CleanupOptionsLabel.Font = New-Font 9 ([System.Drawing.FontStyle]::Bold)
$CleanupOptionsLabel.ForeColor = $Ink
$CleanupOptionsLabel.Location = New-Object System.Drawing.Point(22, 164)
$ControlsPanel.Controls.Add($CleanupOptionsLabel)

$CleanupOptions = New-Object System.Windows.Forms.CheckedListBox
$CleanupOptions.CheckOnClick = $true
$CleanupOptions.Font = New-Font 8
$CleanupOptions.ForeColor = $Ink
$CleanupOptions.BackColor = [System.Drawing.Color]::White
$CleanupOptions.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$CleanupOptions.Size = New-Object System.Drawing.Size(250, 112)
$CleanupOptions.Location = New-Object System.Drawing.Point(24, 186)
$OptionBrowserCache = $CleanupOptions.Items.Add("Browser cache", $true)
$OptionOldLogs = $CleanupOptions.Items.Add("Old logs/crash dumps", $true)
$OptionUpdateLeftovers = $CleanupOptions.Items.Add("Update leftovers", $false)
$OptionAppLeftovers = $CleanupOptions.Items.Add("App leftovers", $false)
$OptionBrowserData = $CleanupOptions.Items.Add("Cookies/history", $false)
$OptionDownloads = $CleanupOptions.Items.Add("Downloads report only", $true)
$OptionDuplicates = $CleanupOptions.Items.Add("Duplicate report only", $false)
$ControlsPanel.Controls.Add($CleanupOptions)

$RecycleCheck = New-Object System.Windows.Forms.CheckBox
$RecycleCheck.Text = "Also empty Recycle Bin"
$RecycleCheck.AutoSize = $true
$RecycleCheck.Font = New-Font 9
$RecycleCheck.ForeColor = $Ink
$RecycleCheck.Location = New-Object System.Drawing.Point(24, 306)
$ControlsPanel.Controls.Add($RecycleCheck)

$RecycleNote = New-Object System.Windows.Forms.Label
$RecycleNote.Text = "Off by default so recoverable files stay recoverable."
$RecycleNote.Size = New-Object System.Drawing.Size(250, 38)
$RecycleNote.Font = New-Font 8
$RecycleNote.ForeColor = $SoftMuted
$RecycleNote.Location = New-Object System.Drawing.Point(25, 332)
$ControlsPanel.Controls.Add($RecycleNote)

$TrustLine = New-Object System.Windows.Forms.Label
$TrustLine.Text = "No telemetry. No personal folders. No background cleanup."
$TrustLine.Size = New-Object System.Drawing.Size(250, 42)
$TrustLine.Font = New-Font 8 ([System.Drawing.FontStyle]::Bold)
$TrustLine.ForeColor = $Brand
$TrustLine.Location = New-Object System.Drawing.Point(24, 374)
$ControlsPanel.Controls.Add($TrustLine)

$PreviewButton = New-Object System.Windows.Forms.Button
$PreviewButton.Text = "Preview Scan"
$PreviewButton.Size = New-Object System.Drawing.Size(250, 44)
$PreviewButton.Location = New-Object System.Drawing.Point(24, 428)
Set-ButtonStyle -Button $PreviewButton -BackColor ([System.Drawing.Color]::FromArgb(230, 239, 236)) -ForeColor $Brand
$ControlsPanel.Controls.Add($PreviewButton)

$CleanButton = New-Object System.Windows.Forms.Button
$CleanButton.Text = "Clean Safely"
$CleanButton.Size = New-Object System.Drawing.Size(250, 50)
$CleanButton.Location = New-Object System.Drawing.Point(24, 484)
Set-ButtonStyle -Button $CleanButton -BackColor $Brand -ForeColor ([System.Drawing.Color]::White)
$ControlsPanel.Controls.Add($CleanButton)

$OpenLogsButton = New-Object System.Windows.Forms.Button
$OpenLogsButton.Text = "Open Logs"
$OpenLogsButton.Size = New-Object System.Drawing.Size(250, 38)
$OpenLogsButton.Location = New-Object System.Drawing.Point(24, 548)
Set-ButtonStyle -Button $OpenLogsButton -BackColor ([System.Drawing.Color]::FromArgb(245, 247, 245)) -ForeColor ([System.Drawing.Color]::FromArgb(64, 75, 70))
$ControlsPanel.Controls.Add($OpenLogsButton)

$Tabs = New-Object System.Windows.Forms.TabControl
$Tabs.Dock = [System.Windows.Forms.DockStyle]::Fill
$Tabs.Font = New-Font 10
$Tabs.Padding = New-Object System.Drawing.Point(18, 8)
$Main.Controls.Add($Tabs, 1, 0)

$ResultsTab = New-Object System.Windows.Forms.TabPage
$ResultsTab.Text = "Results"
$ResultsTab.BackColor = [System.Drawing.Color]::White
$Tabs.Controls.Add($ResultsTab)

$InfoTab = New-Object System.Windows.Forms.TabPage
$InfoTab.Text = "Info"
$InfoTab.BackColor = [System.Drawing.Color]::White
$Tabs.Controls.Add($InfoTab)

$ResultsPanel = New-Object System.Windows.Forms.Panel
$ResultsPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$ResultsPanel.BackColor = $Surface
$ResultsPanel.Padding = New-Object System.Windows.Forms.Padding(18)
$ResultsTab.Controls.Add($ResultsPanel)

$StatusLabel = New-Object System.Windows.Forms.Label
$StatusLabel.Text = "Ready when you are."
$StatusLabel.AutoSize = $true
$StatusLabel.Font = New-Font 15 ([System.Drawing.FontStyle]::Bold)
$StatusLabel.ForeColor = $Ink
$StatusLabel.Location = New-Object System.Drawing.Point(18, 18)
$ResultsPanel.Controls.Add($StatusLabel)

$StatusSubtext = New-Object System.Windows.Forms.Label
$StatusSubtext.Text = "Run a preview first to see what RazorWear can remove."
$StatusSubtext.AutoSize = $true
$StatusSubtext.Font = New-Font 9
$StatusSubtext.ForeColor = $Muted
$StatusSubtext.Location = New-Object System.Drawing.Point(20, 53)
$ResultsPanel.Controls.Add($StatusSubtext)

$StatusChip = New-Object System.Windows.Forms.Label
$StatusChip.Text = "Idle"
$StatusChip.AutoSize = $true
$StatusChip.Font = New-Font 8 ([System.Drawing.FontStyle]::Bold)
$StatusChip.ForeColor = $Brand
$StatusChip.BackColor = $Mint
$StatusChip.Padding = New-Object System.Windows.Forms.Padding(10, 4, 10, 4)
$StatusChip.Location = New-Object System.Drawing.Point(430, 23)
$StatusChip.Anchor = "Top, Right"
$ResultsPanel.Controls.Add($StatusChip)

$OutputBox = New-Object System.Windows.Forms.TextBox
$OutputBox.Multiline = $true
$OutputBox.ReadOnly = $true
$OutputBox.ScrollBars = [System.Windows.Forms.ScrollBars]::None
$OutputBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$OutputBox.BackColor = [System.Drawing.Color]::FromArgb(250, 251, 250)
$OutputBox.ForeColor = [System.Drawing.Color]::FromArgb(42, 50, 47)
$OutputBox.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$OutputBox.Anchor = "Top, Left"
$OutputBox.Location = New-Object System.Drawing.Point(22, 92)
$OutputBox.Size = New-Object System.Drawing.Size(520, 350)
$OutputBox.Text = ""
$ResultsPanel.Controls.Add($OutputBox)

$script:IdlePulse = 0
$IdlePanel = New-Object System.Windows.Forms.Panel
$IdlePanel.Anchor = "Top, Left"
$IdlePanel.Location = $OutputBox.Location
$IdlePanel.Size = $OutputBox.Size
$IdlePanel.BackColor = [System.Drawing.Color]::FromArgb(250, 251, 250)
$IdlePanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$ResultsPanel.Controls.Add($IdlePanel)
$IdlePanel.BringToFront()

$IdleTitle = New-Object System.Windows.Forms.Label
$IdleTitle.Text = "No scan has run yet."
$IdleTitle.AutoSize = $false
$IdleTitle.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$IdleTitle.Font = New-Font 16 ([System.Drawing.FontStyle]::Bold)
$IdleTitle.ForeColor = $Ink
$IdleTitle.Anchor = "Left, Right, Bottom"
$IdleTitle.Location = New-Object System.Drawing.Point(20, 205)
$IdleTitle.Size = New-Object System.Drawing.Size(480, 34)
$IdlePanel.Controls.Add($IdleTitle)
$IdleTitle.Visible = $false

$IdleSubtext = New-Object System.Windows.Forms.Label
$IdleSubtext.Text = "Preview first. Only approved cleanup areas are checked. No information is collected."
$IdleSubtext.AutoSize = $false
$IdleSubtext.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$IdleSubtext.Font = New-Font 9
$IdleSubtext.ForeColor = $Muted
$IdleSubtext.Anchor = "Left, Right, Bottom"
$IdleSubtext.Location = New-Object System.Drawing.Point(60, 244)
$IdleSubtext.Size = New-Object System.Drawing.Size(400, 42)
$IdlePanel.Controls.Add($IdleSubtext)
$IdleSubtext.Visible = $false

$IdlePanel.Add_Paint({
    param($sender, $e)

    $graphics = $e.Graphics
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

    $width = $sender.ClientSize.Width
    $centerX = $width / 2
    $height = $sender.ClientSize.Height
    $centerY = [Math]::Max(74, [Math]::Min(98, $height * 0.28))
    $titleY = $centerY + 62
    $bodyY = $titleY + 34
    $pulse = [Math]::Sin($script:IdlePulse / 12)
    $ringSize = 78 + (5 * $pulse)

    $haloBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(34, $Brand.R, $Brand.G, $Brand.B))
    $ringPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(140, $Brand.R, $Brand.G, $Brand.B), 3)
    $accentPen = New-Object System.Drawing.Pen($Warning, 3)
    $accentPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $accentPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $textBrush = New-Object System.Drawing.SolidBrush($BrandDark)
    $mutedBrush = New-Object System.Drawing.SolidBrush($Muted)
    $font = New-Font 22 ([System.Drawing.FontStyle]::Bold)
    $titleFont = New-Font 16 ([System.Drawing.FontStyle]::Bold)
    $bodyFont = New-Font 9

    $haloRect = New-Object System.Drawing.RectangleF(($centerX - ($ringSize / 2)), ($centerY - ($ringSize / 2)), $ringSize, $ringSize)
    $ringRect = New-Object System.Drawing.RectangleF(($centerX - 38), ($centerY - 38), 76, 76)
    $graphics.FillEllipse($haloBrush, $haloRect)
    $graphics.DrawEllipse($ringPen, $ringRect)
    $graphics.DrawArc($accentPen, $ringRect, (($script:IdlePulse * 4) % 360), 44)

    $textSize = $graphics.MeasureString("RW", $font)
    $graphics.DrawString("RW", $font, $textBrush, $centerX - ($textSize.Width / 2), $centerY - ($textSize.Height / 2))

    $title = "No scan has run yet."
    $titleSize = $graphics.MeasureString($title, $titleFont)
    $graphics.DrawString($title, $titleFont, $textBrush, $centerX - ($titleSize.Width / 2), $titleY)

    $body = "Preview first. Only approved cleanup areas are checked.`nNo information is collected."
    $bodyRect = New-Object System.Drawing.RectangleF(64, $bodyY, ($width - 128), 50)
    $bodyFormat = New-Object System.Drawing.StringFormat
    $bodyFormat.Alignment = [System.Drawing.StringAlignment]::Center
    $bodyFormat.LineAlignment = [System.Drawing.StringAlignment]::Near
    $graphics.DrawString($body, $bodyFont, $mutedBrush, $bodyRect, $bodyFormat)

    $haloBrush.Dispose()
    $ringPen.Dispose()
    $accentPen.Dispose()
    $textBrush.Dispose()
    $mutedBrush.Dispose()
    $font.Dispose()
    $titleFont.Dispose()
    $bodyFont.Dispose()
    $bodyFormat.Dispose()
})

$IdleTimer = New-Object System.Windows.Forms.Timer
$IdleTimer.Interval = 80
$IdleTimer.Add_Tick({
    if ($IdlePanel.Visible -and -not $ActivityPanel.Visible) {
        $script:IdlePulse = ($script:IdlePulse + 1) % 360
        $IdlePanel.Invalidate()
    }
})

$script:AnimationAngle = 0
$ActivityPanel = New-Object System.Windows.Forms.Panel
$ActivityPanel.Anchor = "Top, Left"
$ActivityPanel.Location = $OutputBox.Location
$ActivityPanel.Size = $OutputBox.Size
$ActivityPanel.BackColor = [System.Drawing.Color]::FromArgb(250, 251, 250)
$ActivityPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$ActivityPanel.Visible = $false
$ResultsPanel.Controls.Add($ActivityPanel)
$ActivityPanel.BringToFront()

$ActivityText = New-Object System.Windows.Forms.Label
$ActivityText.Text = "Cleaning safely..."
$ActivityText.AutoSize = $false
$ActivityText.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$ActivityText.Font = New-Font 12 ([System.Drawing.FontStyle]::Bold)
$ActivityText.ForeColor = $Brand
$ActivityText.Dock = [System.Windows.Forms.DockStyle]::Bottom
$ActivityText.Height = 70
$ActivityPanel.Controls.Add($ActivityText)

$ActivityPanel.Add_Paint({
    param($sender, $e)

    $graphics = $e.Graphics
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

    $width = $sender.ClientSize.Width
    $height = $sender.ClientSize.Height - 58
    $size = [Math]::Min($width, $height) - 110
    if ($size -lt 120) { $size = 120 }

    $x = ($width - $size) / 2
    $y = (($height - $size) / 2) + 18
    $rect = New-Object System.Drawing.RectangleF($x, $y, $size, $size)

    $basePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(224, 236, 232), 12)
    $sweepPen = New-Object System.Drawing.Pen($Brand, 12)
    $sweepPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $sweepPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $razorPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(191, 123, 54), 4)
    $razorPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $razorPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round

    $graphics.DrawEllipse($basePen, $rect)
    $graphics.DrawArc($sweepPen, $rect, $script:AnimationAngle, 104)
    $graphics.DrawArc($razorPen, $rect, $script:AnimationAngle + 118, 28)

    $centerX = $x + ($size / 2)
    $centerY = $y + ($size / 2)
    $font = New-Font 28 ([System.Drawing.FontStyle]::Bold)
    $brush = New-Object System.Drawing.SolidBrush($BrandDark)
    $textSize = $graphics.MeasureString("RW", $font)
    $graphics.DrawString("RW", $font, $brush, $centerX - ($textSize.Width / 2), $centerY - ($textSize.Height / 2))

    $basePen.Dispose()
    $sweepPen.Dispose()
    $razorPen.Dispose()
    $font.Dispose()
    $brush.Dispose()
})

$ActivityTimer = New-Object System.Windows.Forms.Timer
$ActivityTimer.Interval = 35
$ActivityTimer.Add_Tick({
    $script:AnimationAngle = ($script:AnimationAngle + 8) % 360
    $ActivityPanel.Invalidate()
})

$SafetyLine = New-Object System.Windows.Forms.Label
$SafetyLine.Text = "Protected: Desktop, Documents, Downloads, Pictures, Music, Videos, OneDrive, saved passwords."
$SafetyLine.Anchor = "Bottom, Left, Right"
$SafetyLine.Size = New-Object System.Drawing.Size(520, 34)
$SafetyLine.Font = New-Font 8
$SafetyLine.ForeColor = $Muted
$SafetyLine.Location = New-Object System.Drawing.Point(23, 456)
$ResultsPanel.Controls.Add($SafetyLine)

function Update-ResultsLayout {
    $availableWidth = $ResultsPanel.ClientSize.Width - 44
    $availableHeight = $ResultsPanel.ClientSize.Height - 150
    if ($availableWidth -lt 360) { $availableWidth = 360 }
    if ($availableHeight -lt 220) { $availableHeight = 220 }

    $areaLocation = New-Object System.Drawing.Point(22, 92)
    $areaSize = New-Object System.Drawing.Size($availableWidth, $availableHeight)
    foreach ($control in @($OutputBox, $IdlePanel, $ActivityPanel)) {
        $control.Location = $areaLocation
        $control.Size = $areaSize
    }

    $SafetyLine.Location = New-Object System.Drawing.Point(23, ($ResultsPanel.ClientSize.Height - 42))
    $SafetyLine.Size = New-Object System.Drawing.Size(($ResultsPanel.ClientSize.Width - 46), 34)
}

$ResultsPanel.Add_Resize({
    Update-ResultsLayout
})

$InfoPanel = New-Object System.Windows.Forms.Panel
$InfoPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$InfoPanel.BackColor = $Surface
$InfoPanel.Padding = New-Object System.Windows.Forms.Padding(24)
$InfoTab.Controls.Add($InfoPanel)

$InfoTitle = New-Object System.Windows.Forms.Label
$InfoTitle.Text = "Safe, simple, reliable cleanup."
$InfoTitle.AutoSize = $true
$InfoTitle.Font = New-Font 18 ([System.Drawing.FontStyle]::Bold)
$InfoTitle.ForeColor = $Ink
$InfoTitle.Location = New-Object System.Drawing.Point(24, 24)
$InfoPanel.Controls.Add($InfoTitle)

$InfoIntro = New-Object System.Windows.Forms.Label
$InfoIntro.Text = "RazorWear is built to clean everyday system clutter without grabbing your information or touching the things that matter."
$InfoIntro.Size = New-Object System.Drawing.Size(520, 54)
$InfoIntro.Font = New-Font 10
$InfoIntro.ForeColor = $Muted
$InfoIntro.Location = New-Object System.Drawing.Point(27, 68)
$InfoPanel.Controls.Add($InfoIntro)

$InfoScrollPanel = New-Object System.Windows.Forms.Panel
$InfoScrollPanel.Anchor = "Top, Bottom, Left, Right"
$InfoScrollPanel.AutoScroll = $true
$InfoScrollPanel.BackColor = [System.Drawing.Color]::FromArgb(250, 251, 250)
$InfoScrollPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$InfoScrollPanel.Location = New-Object System.Drawing.Point(30, 132)
$InfoScrollPanel.Size = New-Object System.Drawing.Size(512, 294)
$InfoPanel.Controls.Add($InfoScrollPanel)

function Add-InfoSection {
    param(
        [string]$Heading,
        [string]$Body,
        [int]$Top
    )

    $headingLabel = New-Object System.Windows.Forms.Label
    $headingLabel.Text = $Heading
    $headingLabel.AutoSize = $false
    $headingLabel.Size = New-Object System.Drawing.Size(462, 24)
    $headingLabel.Font = New-Font 10 ([System.Drawing.FontStyle]::Bold)
    $headingLabel.ForeColor = $Brand
    $headingLabel.Location = New-Object System.Drawing.Point(18, $Top)
    $InfoScrollPanel.Controls.Add($headingLabel)

    $bodyLabel = New-Object System.Windows.Forms.Label
    $bodyLabel.Text = $Body
    $bodyLabel.AutoSize = $false
    $bodyLabel.Size = New-Object System.Drawing.Size(462, 52)
    $bodyLabel.Font = New-Font 9
    $bodyLabel.ForeColor = [System.Drawing.Color]::FromArgb(42, 50, 47)
    $bodyLabel.Location = New-Object System.Drawing.Point(18, ($Top + 25))
    $InfoScrollPanel.Controls.Add($bodyLabel)
}

Add-InfoSection -Heading "No info grabbing" -Body "RazorWear does not collect your name, email, files, location, device ID, browsing history, or usage analytics." -Top 18
Add-InfoSection -Heading "No tracking" -Body "RazorWear does not include ads, telemetry, third-party trackers, or a background service." -Top 104
Add-InfoSection -Heading "Safe cleanup" -Body "Cleanup targets selected safe areas such as temp files, browser cache, old logs, update leftovers, and old installer leftovers. Downloads and duplicates are report-only." -Top 190
Add-InfoSection -Heading "Simple and reliable" -Body "You can preview before cleaning, choose whether to include the Recycle Bin, and review local logs on your own computer." -Top 292

$InfoFooter = New-Object System.Windows.Forms.Label
$InfoFooter.Text = "Local logs stay local. RazorWear does not connect to the internet."
$InfoFooter.Anchor = "Bottom, Left, Right"
$InfoFooter.Size = New-Object System.Drawing.Size(512, 30)
$InfoFooter.Font = New-Font 9 ([System.Drawing.FontStyle]::Bold)
$InfoFooter.ForeColor = $Brand
$InfoFooter.Location = New-Object System.Drawing.Point(30, 450)
$InfoPanel.Controls.Add($InfoFooter)

function Update-InfoLayout {
    $contentWidth = $InfoPanel.ClientSize.Width - 60
    if ($contentWidth -lt 360) { $contentWidth = 360 }

    $InfoIntro.Size = New-Object System.Drawing.Size($contentWidth, 54)
    $InfoScrollPanel.Size = New-Object System.Drawing.Size($contentWidth, ($InfoPanel.ClientSize.Height - 196))
    if ($InfoScrollPanel.Height -lt 220) {
        $InfoScrollPanel.Height = 220
    }
    $sectionWidth = $InfoScrollPanel.ClientSize.Width - 40
    if ($sectionWidth -lt 320) { $sectionWidth = 320 }
    foreach ($control in $InfoScrollPanel.Controls) {
        $control.Width = $sectionWidth
    }
    $InfoFooter.Location = New-Object System.Drawing.Point(30, ($InfoPanel.ClientSize.Height - 42))
    $InfoFooter.Size = New-Object System.Drawing.Size($contentWidth, 30)
}

$InfoPanel.Add_Resize({
    Update-InfoLayout
})

function Set-OutputText {
    param([string]$Text)

    $DisplayText = Format-RazorWearOutput -Text $Text
    $OutputBox.Text = $DisplayText
    $lineCount = @($DisplayText -split "\r?\n").Count
    if ($lineCount -gt 18 -or $DisplayText.Length -gt 1400) {
        $OutputBox.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
    }
    else {
        $OutputBox.ScrollBars = [System.Windows.Forms.ScrollBars]::None
    }
}

function Format-RazorWearOutput {
    param([string]$Text)

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return ""
    }

    $normalized = $Text.Trim()
    $normalized = $normalized -replace "(\])\s*(?=\[\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}\])", "`r`n"
    $normalized = $normalized -replace "\s*(?=\[\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}\]\s+Scanning:)", "`r`n"
    $normalized = $normalized -replace "\s*(?=\[\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}\]\s+Recycle Bin)", "`r`n"
    $normalized = $normalized -replace "\s*(?=\[\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}\]\s+Downloads clutter)", "`r`n"
    $normalized = $normalized -replace "\s*(?=\[\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}\]\s+Duplicate file)", "`r`n"
    $normalized = $normalized -replace "\r?\n{3,}", "`r`n`r`n"

    return $normalized
}

function Show-OutputView {
    $IdlePanel.Visible = $false
    $OutputBox.Visible = $true
    $OutputBox.BringToFront()
}

function Show-IdleView {
    Set-OutputText ""
    $OutputBox.Visible = $false
    $IdlePanel.Visible = $true
    $IdlePanel.BringToFront()
}

function Set-BusyState {
    param(
        [bool]$Busy,
        [string]$ActivityMessage = "Working safely..."
    )

    $PreviewButton.Enabled = -not $Busy
    $CleanButton.Enabled = -not $Busy
    $OpenLogsButton.Enabled = -not $Busy
    $AgeInput.Enabled = -not $Busy
    $RecycleCheck.Enabled = -not $Busy
    $CleanupOptions.Enabled = -not $Busy
    $ActivityText.Text = $ActivityMessage
    $ActivityPanel.Visible = $Busy
    if ($Busy) {
        $IdlePanel.Visible = $false
        $ActivityPanel.BringToFront()
        $ActivityTimer.Start()
    }
    else {
        $ActivityTimer.Stop()
    }
    [System.Windows.Forms.Application]::DoEvents()
}

$script:OperationBusy = $false

function Complete-RazorWearOperation {
    param([object]$Job)

    try {
        $output = Invoke-RazorWear `
            -Mode $Job.Mode `
            -OlderThanDays $Job.OlderThanDays `
            -IncludeRecycleBin $Job.IncludeRecycleBin `
            -IncludeBrowserCache $Job.IncludeBrowserCache `
            -IncludeOldLogs $Job.IncludeOldLogs `
            -IncludeUpdateLeftovers $Job.IncludeUpdateLeftovers `
            -IncludeAppLeftovers $Job.IncludeAppLeftovers `
            -IncludeBrowserData $Job.IncludeBrowserData `
            -AnalyzeDownloads $Job.AnalyzeDownloads `
            -FindDuplicates $Job.FindDuplicates

        Set-BusyState $false
        Show-OutputView
        Set-OutputText $output

        if ($Job.Mode -eq "Preview") {
            $StatusChip.Text = "Preview ready"
            $StatusChip.ForeColor = $Success
            $StatusChip.BackColor = $SuccessBack
            $StatusLabel.Text = "Preview complete."
            $StatusLabel.ForeColor = $Success
            $StatusSubtext.Text = "Review the results, then clean only if everything looks right."
        }
        else {
            $StatusChip.Text = "Clean"
            $StatusChip.ForeColor = $Success
            $StatusChip.BackColor = $SuccessBack
            $StatusLabel.Text = "Cleanup complete."
            $StatusLabel.ForeColor = $Success
            $StatusSubtext.Text = "A local log was saved in the logs folder."
        }
    }
    catch {
        Set-BusyState $false
        Show-OutputView
        Set-OutputText $_.Exception.Message
        $StatusChip.Text = "Needs attention"
        $StatusChip.ForeColor = $Warning
        $StatusChip.BackColor = [System.Drawing.Color]::FromArgb(251, 237, 222)
        $StatusLabel.Text = "Something needs attention."
        $StatusLabel.ForeColor = $Warning
        $StatusSubtext.Text = "RazorWear stopped before finishing."
    }
    finally {
        $script:OperationBusy = $false
    }
}

function Start-RazorWearOperation {
    param([string]$Mode)

    if ($script:OperationBusy) {
        return
    }

    $isPreview = $Mode -eq "Preview"
    $StatusChip.Text = if ($isPreview) { "Scanning" } else { "Cleaning" }
    $StatusChip.ForeColor = $Warning
    $StatusChip.BackColor = [System.Drawing.Color]::FromArgb(251, 237, 222)
    $StatusLabel.Text = if ($isPreview) { "Scanning..." } else { "Cleaning..." }
    $StatusLabel.ForeColor = $Ink
    $StatusSubtext.Text = if ($isPreview) {
        "Preview mode checks selected cleanup areas without deleting anything."
    }
    else {
        "RazorWear is cleaning only the selected approved areas."
    }
    Show-OutputView
    Set-OutputText $(if ($isPreview) { "Scanning selected cleanup locations..." } else { "Cleaning selected safe locations..." })

    $script:OperationBusy = $true
    Set-BusyState $true $(if ($isPreview) { "Scanning safely..." } else { "Cleaning safely..." })

    Complete-RazorWearOperation -Job ([pscustomobject]@{
        Mode = $Mode
        OlderThanDays = [int]$AgeInput.Value
        IncludeRecycleBin = $RecycleCheck.Checked
        IncludeBrowserCache = $CleanupOptions.GetItemChecked($OptionBrowserCache)
        IncludeOldLogs = $CleanupOptions.GetItemChecked($OptionOldLogs)
        IncludeUpdateLeftovers = $CleanupOptions.GetItemChecked($OptionUpdateLeftovers)
        IncludeAppLeftovers = $CleanupOptions.GetItemChecked($OptionAppLeftovers)
        IncludeBrowserData = $CleanupOptions.GetItemChecked($OptionBrowserData)
        AnalyzeDownloads = $CleanupOptions.GetItemChecked($OptionDownloads)
        FindDuplicates = $CleanupOptions.GetItemChecked($OptionDuplicates)
    })
}

$PreviewButton.Add_Click({
    Start-RazorWearOperation -Mode "Preview"
})

$CleanButton.Add_Click({
    $message = "RazorWear will remove selected cleanable files older than $($AgeInput.Value) day(s)."
    $message += "`r`n`r`nDownloads and duplicate reports are never auto-deleted."
    if ($RecycleCheck.Checked) {
        $message += "`r`n`r`nYou also selected Recycle Bin cleanup."
    }
    if ($CleanupOptions.GetItemChecked($OptionBrowserData)) {
        $message += "`r`n`r`nYou also selected browser cookies/history cleanup. Close browsers first for best results."
    }

    $confirm = [System.Windows.Forms.MessageBox]::Show(
        $message,
        "Confirm cleanup",
        [System.Windows.Forms.MessageBoxButtons]::OKCancel,
        [System.Windows.Forms.MessageBoxIcon]::Information
    )

    if ($confirm -ne [System.Windows.Forms.DialogResult]::OK) {
        return
    }

    Start-RazorWearOperation -Mode "Clean"
})

$OpenLogsButton.Add_Click({
    $LogDir = Join-Path $AppRoot "logs"
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
    Start-Process explorer.exe $LogDir
})

$ExitMenuItem.Add_Click({
    $Form.Close()
})

$AboutMenuItem.Add_Click({
    [System.Windows.Forms.MessageBox]::Show(
        "RazorWear $VersionText`r`n`r`nPrivate cleanup for Windows temp files.`r`nNo accounts. No telemetry. No background service.",
        "About RazorWear",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    ) | Out-Null
})

$ReportBugMenuItem.Add_Click({
    $message = "Open the RazorWear GitHub issue page in your browser?`r`n`r`nRazorWear itself will not send logs or device information."
    $confirm = [System.Windows.Forms.MessageBox]::Show(
        $message,
        "Report a bug",
        [System.Windows.Forms.MessageBoxButtons]::OKCancel,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )

    if ($confirm -eq [System.Windows.Forms.DialogResult]::OK) {
        Start-Process "https://github.com/Renoman1195/Test-Products/issues/new?title=RazorWear%20bug%20report"
    }
})

$Form.Add_Shown({
    Update-ResultsLayout
    Update-InfoLayout
    Show-IdleView
    $IdleTimer.Start()
})

$Form.Add_FormClosed({
    $IdleTimer.Stop()
    $ActivityTimer.Stop()
})

[void]$Form.ShowDialog()
