Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = "Stop"

$AppRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$CleanerPath = Join-Path $AppRoot "RazorWear.ps1"

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

function Invoke-RazorWear {
    param(
        [string]$Mode,
        [int]$OlderThanDays,
        [bool]$IncludeRecycleBin
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
$Form.Size = New-Object System.Drawing.Size(940, 660)
$Form.MinimumSize = New-Object System.Drawing.Size(940, 660)
$Form.BackColor = $Canvas
$Form.Font = New-Font 9

$Header = New-Object System.Windows.Forms.Panel
$Header.Dock = [System.Windows.Forms.DockStyle]::Top
$Header.Height = 132
$Header.BackColor = $BrandDark
$Form.Controls.Add($Header)

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
$Subtitle.Size = New-Object System.Drawing.Size(600, 24)
$Subtitle.Font = New-Font 10
$Subtitle.ForeColor = [System.Drawing.Color]::FromArgb(221, 239, 232)
$Subtitle.Location = New-Object System.Drawing.Point(116, 70)
$Header.Controls.Add($Subtitle)

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
$VersionBadge.Text = "0.5.0 preview"
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
$Form.Controls.Add($Main)

$ControlsPanel = New-Object System.Windows.Forms.Panel
$ControlsPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$ControlsPanel.BackColor = $Surface
$ControlsPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$ControlsPanel.Padding = New-Object System.Windows.Forms.Padding(18)
$Main.Controls.Add($ControlsPanel, 0, 0)

$OptionsTitle = New-Object System.Windows.Forms.Label
$OptionsTitle.Text = "Clean without the creep."
$OptionsTitle.AutoSize = $true
$OptionsTitle.Font = New-Font 14 ([System.Drawing.FontStyle]::Bold)
$OptionsTitle.ForeColor = $Ink
$OptionsTitle.Location = New-Object System.Drawing.Point(20, 20)
$ControlsPanel.Controls.Add($OptionsTitle)

$OptionsText = New-Object System.Windows.Forms.Label
$OptionsText.Text = "RazorWear clears approved temp folders while leaving your personal files alone."
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
$AgeLabel.Location = New-Object System.Drawing.Point(22, 132)
$ControlsPanel.Controls.Add($AgeLabel)

$AgeInput = New-Object System.Windows.Forms.NumericUpDown
$AgeInput.Minimum = 1
$AgeInput.Maximum = 30
$AgeInput.Value = 1
$AgeInput.Width = 72
$AgeInput.Location = New-Object System.Drawing.Point(24, 162)
$AgeInput.Font = New-Font 11
$ControlsPanel.Controls.Add($AgeInput)

$DaysLabel = New-Object System.Windows.Forms.Label
$DaysLabel.Text = "day(s)"
$DaysLabel.AutoSize = $true
$DaysLabel.Font = New-Font 10
$DaysLabel.ForeColor = $Muted
$DaysLabel.Location = New-Object System.Drawing.Point(106, 166)
$ControlsPanel.Controls.Add($DaysLabel)

$RecycleCheck = New-Object System.Windows.Forms.CheckBox
$RecycleCheck.Text = "Also empty Recycle Bin"
$RecycleCheck.AutoSize = $true
$RecycleCheck.Font = New-Font 9
$RecycleCheck.ForeColor = $Ink
$RecycleCheck.Location = New-Object System.Drawing.Point(24, 216)
$ControlsPanel.Controls.Add($RecycleCheck)

$RecycleNote = New-Object System.Windows.Forms.Label
$RecycleNote.Text = "Off by default so recoverable files stay recoverable."
$RecycleNote.Size = New-Object System.Drawing.Size(250, 38)
$RecycleNote.Font = New-Font 8
$RecycleNote.ForeColor = $SoftMuted
$RecycleNote.Location = New-Object System.Drawing.Point(25, 244)
$ControlsPanel.Controls.Add($RecycleNote)

$TrustLine = New-Object System.Windows.Forms.Label
$TrustLine.Text = "No telemetry. No personal folders. No background cleanup."
$TrustLine.Size = New-Object System.Drawing.Size(250, 42)
$TrustLine.Font = New-Font 8 ([System.Drawing.FontStyle]::Bold)
$TrustLine.ForeColor = $Brand
$TrustLine.Location = New-Object System.Drawing.Point(24, 292)
$ControlsPanel.Controls.Add($TrustLine)

$PreviewButton = New-Object System.Windows.Forms.Button
$PreviewButton.Text = "Preview Scan"
$PreviewButton.Size = New-Object System.Drawing.Size(250, 44)
$PreviewButton.Location = New-Object System.Drawing.Point(24, 350)
Set-ButtonStyle -Button $PreviewButton -BackColor ([System.Drawing.Color]::FromArgb(230, 239, 236)) -ForeColor $Brand
$ControlsPanel.Controls.Add($PreviewButton)

$CleanButton = New-Object System.Windows.Forms.Button
$CleanButton.Text = "Clean Safely"
$CleanButton.Size = New-Object System.Drawing.Size(250, 50)
$CleanButton.Location = New-Object System.Drawing.Point(24, 406)
Set-ButtonStyle -Button $CleanButton -BackColor $Brand -ForeColor ([System.Drawing.Color]::White)
$ControlsPanel.Controls.Add($CleanButton)

$OpenLogsButton = New-Object System.Windows.Forms.Button
$OpenLogsButton.Text = "Open Logs"
$OpenLogsButton.Size = New-Object System.Drawing.Size(250, 38)
$OpenLogsButton.Location = New-Object System.Drawing.Point(24, 474)
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
$OutputBox.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
$OutputBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$OutputBox.BackColor = [System.Drawing.Color]::FromArgb(250, 251, 250)
$OutputBox.ForeColor = [System.Drawing.Color]::FromArgb(42, 50, 47)
$OutputBox.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$OutputBox.Anchor = "Top, Bottom, Left, Right"
$OutputBox.Location = New-Object System.Drawing.Point(22, 92)
$OutputBox.Size = New-Object System.Drawing.Size(520, 350)
$OutputBox.Text = "No scan has run yet.`r`n`r`nRazorWear does not connect to the internet or collect any information."
$ResultsPanel.Controls.Add($OutputBox)

$script:AnimationAngle = 0
$ActivityPanel = New-Object System.Windows.Forms.Panel
$ActivityPanel.Anchor = "Top, Bottom, Left, Right"
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

$InfoBox = New-Object System.Windows.Forms.TextBox
$InfoBox.Multiline = $true
$InfoBox.ReadOnly = $true
$InfoBox.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$InfoBox.BackColor = [System.Drawing.Color]::FromArgb(250, 251, 250)
$InfoBox.ForeColor = [System.Drawing.Color]::FromArgb(42, 50, 47)
$InfoBox.Font = New-Font 10
$InfoBox.Anchor = "Top, Bottom, Left, Right"
$InfoBox.Location = New-Object System.Drawing.Point(30, 142)
$InfoBox.Size = New-Object System.Drawing.Size(512, 284)
$InfoBox.Text = @"
No info grabbing
RazorWear does not collect your name, email, files, location, device ID, browsing history, or usage analytics.

No tracking
RazorWear does not include ads, telemetry, third-party trackers, or a background service.

Safe cleanup
Regular cleanup only targets approved temporary folders. Desktop, Documents, Downloads, Pictures, Music, Videos, OneDrive, saved passwords, and personal files stay untouched.

Simple and reliable
You can preview before cleaning, choose whether to include the Recycle Bin, and review local logs on your own computer.
"@
$InfoPanel.Controls.Add($InfoBox)

$InfoFooter = New-Object System.Windows.Forms.Label
$InfoFooter.Text = "Local logs stay local. RazorWear does not connect to the internet."
$InfoFooter.Anchor = "Bottom, Left, Right"
$InfoFooter.Size = New-Object System.Drawing.Size(512, 30)
$InfoFooter.Font = New-Font 9 ([System.Drawing.FontStyle]::Bold)
$InfoFooter.ForeColor = $Brand
$InfoFooter.Location = New-Object System.Drawing.Point(30, 450)
$InfoPanel.Controls.Add($InfoFooter)

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
    $ActivityText.Text = $ActivityMessage
    $ActivityPanel.Visible = $Busy
    if ($Busy) {
        $ActivityPanel.BringToFront()
        $ActivityTimer.Start()
    }
    else {
        $ActivityTimer.Stop()
    }
    [System.Windows.Forms.Application]::DoEvents()
}

$Worker = New-Object System.ComponentModel.BackgroundWorker
$Worker.Add_DoWork({
    param($sender, $eventArgs)

    $job = $eventArgs.Argument
    $output = Invoke-RazorWear -Mode $job.Mode -OlderThanDays $job.OlderThanDays -IncludeRecycleBin $job.IncludeRecycleBin
    $eventArgs.Result = [pscustomobject]@{
        Mode = $job.Mode
        Output = $output
    }
})

$Worker.Add_RunWorkerCompleted({
    param($sender, $eventArgs)

    Set-BusyState $false

    if ($eventArgs.Error) {
        $OutputBox.Text = $eventArgs.Error.Message
        $StatusChip.Text = "Needs attention"
        $StatusChip.ForeColor = $Warning
        $StatusLabel.Text = "Something needs attention."
        $StatusSubtext.Text = "RazorWear stopped before finishing."
        return
    }

    $result = $eventArgs.Result
    $OutputBox.Text = $result.Output

    if ($result.Mode -eq "Preview") {
        $StatusChip.Text = "Preview ready"
        $StatusChip.ForeColor = $Brand
        $StatusLabel.Text = "Preview complete."
        $StatusSubtext.Text = "Review the results, then clean only if everything looks right."
    }
    else {
        $StatusChip.Text = "Clean"
        $StatusChip.ForeColor = $Brand
        $StatusLabel.Text = "Cleanup complete."
        $StatusSubtext.Text = "A local log was saved in the logs folder."
    }
})

function Start-RazorWearOperation {
    param([string]$Mode)

    if ($Worker.IsBusy) {
        return
    }

    $isPreview = $Mode -eq "Preview"
    $StatusChip.Text = if ($isPreview) { "Scanning" } else { "Cleaning" }
    $StatusChip.ForeColor = $Warning
    $StatusLabel.Text = if ($isPreview) { "Scanning..." } else { "Cleaning..." }
    $StatusSubtext.Text = if ($isPreview) {
        "Preview mode checks safe temp folders without deleting anything."
    }
    else {
        "RazorWear is removing only approved temporary files."
    }
    $OutputBox.Text = if ($isPreview) { "Scanning safe cleanup locations..." } else { "Cleaning safe temp locations..." }

    Set-BusyState $true $(if ($isPreview) { "Scanning safely..." } else { "Cleaning safely..." })

    $Worker.RunWorkerAsync([pscustomobject]@{
        Mode = $Mode
        OlderThanDays = [int]$AgeInput.Value
        IncludeRecycleBin = $RecycleCheck.Checked
    })
}

$PreviewButton.Add_Click({
    Start-RazorWearOperation -Mode "Preview"
})

$CleanButton.Add_Click({
    $message = "RazorWear will remove old temporary files from approved temp folders only."
    if ($RecycleCheck.Checked) {
        $message += "`r`n`r`nYou also selected Recycle Bin cleanup."
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

[void]$Form.ShowDialog()
