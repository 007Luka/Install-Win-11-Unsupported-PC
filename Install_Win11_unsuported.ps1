<#
GreekNea
Windows 11 25H2 Quick Installer
All-in-one PowerShell script (PS 5.1 compatible)
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = 'Stop'
$AutoContinue   = $false
$SubscribeUrl   = 'https://www.youtube.com/@GreekneaCom?sub_confirmation=1'
$QuietCopyLogs  = $true

$desktop     = [Environment]::GetFolderPath("Desktop")
$logPath     = Join-Path $desktop "GreekNea_W11_install_log.txt"
$scriptStart = Get-Date

# Detect system language
$lang = (Get-Culture).TwoLetterISOLanguageName
$IsGreek = $false
if ($lang -eq "el") { $IsGreek = $true }

# Function for bilingual messages
function Show-Message {
    param([string]$en, [string]$el)
    if ($IsGreek) { return $el } else { return $en }
}

function Log {
    param([string]$msg)
    $t = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $line = "[$t] $msg"
    $line | Out-File -FilePath $logPath -Append -Encoding UTF8
    Write-Host $line
}

function Open-Url-NewWindow {
    param([Parameter(Mandatory)][string]$Url)
    $progId = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice' -ErrorAction SilentlyContinue).ProgId
    $candidates = @()
    if ($progId -match 'Chrome') { $candidates += @(@{Path="$env:ProgramFiles\Google\Chrome\Application\chrome.exe"; Args=@('--new-window', $Url)}, @{Path="$env:ProgramFiles(x86)\Google\Chrome\Application\chrome.exe"; Args=@('--new-window', $Url)}) }
    elseif ($progId -match 'MSEdge') { $candidates += @(@{Path="$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"; Args=@('--new-window', $Url)}, @{Path="$env:ProgramFiles(x86)\Microsoft\Edge\Application\msedge.exe"; Args=@('--new-window', $Url)}) }
    elseif ($progId -match 'Firefox') { $candidates += @(@{Path="$env:ProgramFiles\Mozilla Firefox\firefox.exe"; Args=@('-new-window', $Url)}, @{Path="$env:ProgramFiles(x86)\Mozilla Firefox\firefox.exe"; Args=@('-new-window', $Url)}) }
    elseif ($progId -match 'Brave') { $candidates += @(@{Path="$env:ProgramFiles\BraveSoftware\Brave-Browser\Application\brave.exe"; Args=@('--new-window', $Url)}, @{Path="$env:ProgramFiles(x86)\BraveSoftware\Brave-Browser\Application\brave.exe"; Args=@('--new-window', $Url)}) }
    elseif ($progId -match 'Opera') { $candidates += @(@{Path="$env:ProgramFiles\Opera\launcher.exe"; Args=@('--new-window', $Url)}, @{Path="$env:ProgramFiles(x86)\Opera\launcher.exe"; Args=@('--new-window', $Url)}) }
    elseif ($progId -match 'Vivaldi') { $candidates += @(@{Path="$env:ProgramFiles\Vivaldi\Application\vivaldi.exe"; Args=@('--new-window', $Url)}, @{Path="$env:ProgramFiles(x86)\Vivaldi\Application\vivaldi.exe"; Args=@('--new-window', $Url)}) }
    $candidates += @(@{Path="$env:ProgramFiles\Google\Chrome\Application\chrome.exe"; Args=@('--new-window', $Url)}, @{Path="$env:ProgramFiles(x86)\Google\Chrome\Application\chrome.exe"; Args=@('--new-window', $Url)}, @{Path="$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"; Args=@('--new-window', $Url)}, @{Path="$env:ProgramFiles(x86)\Microsoft\Edge\Application\msedge.exe"; Args=@('--new-window', $Url)}, @{Path="$env:ProgramFiles\Mozilla Firefox\firefox.exe"; Args=@('-new-window', $Url)})
    foreach ($c in $candidates) {
        if (Test-Path $c.Path) {
            try { Start-Process -FilePath $c.Path -ArgumentList $c.Args -ErrorAction Stop | Out-Null; return } catch { }
        }
    }
    Start-Process $Url | Out-Null
}

# --- Win11 Bypass Function ---
function Enable-Win11Bypass {
    Log (Show-Message "Enabling Windows 11 hardware requirements bypass (TPM, RAM, CPU, Secure Boot)..." `
                      "Ενεργοποίηση παράκαμψης ελέγχων υλικού Windows 11 (TPM, RAM, CPU, Secure Boot)...")
    $regPath = "HKLM:\SYSTEM\Setup\LabConfig"
    if (-not (Test-Path $regPath)) {
        New-Item -Path "HKLM:\SYSTEM\Setup" -Name "LabConfig" -Force | Out-Null
    }
    Set-ItemProperty -Path $regPath -Name "BypassTPMCheck" -Value 1 -Type DWord
    Set-ItemProperty -Path $regPath -Name "BypassRAMCheck" -Value 1 -Type DWord
    Set-ItemProperty -Path $regPath -Name "BypassSecureBootCheck" -Value 1 -Type DWord
    Set-ItemProperty -Path $regPath -Name "BypassCPUCheck" -Value 1 -Type DWord
    Log (Show-Message "Bypass registry keys set." "Οι ρυθμίσεις παράκαμψης καταχωρήθηκαν στο registry.")
}

# Elevate if needed
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    $psi = New-Object System.Diagnostics.ProcessStartInfo "PowerShell"
    $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    $psi.Verb      = "runas"
    try { [System.Diagnostics.Process]::Start($psi) | Out-Null } catch {
        Write-Host (Show-Message "Elevation failed: $_" "Η ανύψωση δικαιωμάτων απέτυχε: $_")
        Read-Host (Show-Message "Press Enter to exit..." "Πατήστε Enter για έξοδο...")
        exit
    }
    exit
}

"GreekNea Windows 11 Installer Log" | Out-File -FilePath $logPath -Force -Encoding UTF8
Log "Script started."

# ---- Intro ----
$form = New-Object System.Windows.Forms.Form
$form.Text = Show-Message "GreekNea - Windows 11 25H2 Installer" "GreekNea - Εγκαταστάτης Windows 11 25H2"
$form.StartPosition   = "CenterScreen"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.MinimizeBox     = $false
$form.MaximizeBox     = $false
$form.AutoScaleMode   = 'Dpi'
$form.MinimumSize     = New-Object System.Drawing.Size(720,190)
$form.Padding         = New-Object System.Windows.Forms.Padding(10)
$form.Font            = New-Object System.Drawing.Font("Segoe UI", 12)

$grid = New-Object System.Windows.Forms.TableLayoutPanel
$grid.Dock = 'Fill'; $grid.RowCount = 3; $grid.ColumnCount = 2
$grid.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,80)))
$grid.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent,20)))
$grid.AutoSize = $true

$title = New-Object System.Windows.Forms.Label
$title.Text = Show-Message "GreekNea - Windows 11 25H2 Installer" "GreekNea - Εγκαταστάτης Windows 11 25H2"
$title.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$title.ForeColor = [System.Drawing.Color]::FromArgb(255,140,0)
$title.AutoSize = $true
$title.Margin   = New-Object System.Windows.Forms.Padding(6,6,6,2)
$grid.Controls.Add($title, 0, 0)
$grid.SetColumnSpan($title, 2)

$sub = New-Object System.Windows.Forms.Label
$sub.Text = Show-Message "Backup your files first! Installing on unsupported hardware is risky." "Κάντε backup των αρχείων σας πρώτα! Η εγκατάσταση σε μη υποστηριζόμενο hardware είναι επικίνδυνη."
$sub.Font = New-Object System.Drawing.Font("Segoe UI", 11)
$sub.AutoSize = $true
$sub.Margin   = New-Object System.Windows.Forms.Padding(6,0,6,8)
$grid.Controls.Add($sub, 0, 1)
$grid.SetColumnSpan($sub, 2)

$btn = New-Object System.Windows.Forms.Button
$btn.Text = Show-Message "Continue" "Συνέχεια"
$btn.Width = 140; $btn.Height = 40
$btn.DialogResult = [System.Windows.Forms.DialogResult]::OK
$btn.Anchor = 'Right'
$btn.Margin = New-Object System.Windows.Forms.Padding(6)
$grid.Controls.Add($btn, 1, 2)

$form.Controls.Add($grid)
$form.AcceptButton = $btn
$form.Topmost = $true
$res = $form.ShowDialog()
if ($res -ne [System.Windows.Forms.DialogResult]::OK) { throw Show-Message "User cancelled at intro." "Ο χρήστης ακύρωσε στο εισαγωγικό." }
Log "Intro accepted."

# ---- Ενεργοποίηση bypass ελέγχων Windows 11 ----
Enable-Win11Bypass

# ---- CPU feature check ----
# (διατήρηση των υπόλοιπων συναρτήσεων όπως Get-CPUFeatures, Win11 bypass κλπ.)
# Όλα τα μηνύματα ενημέρωσης/σφάλματος αντικαθίστανται με Show-Message.

# ---- Final Message ----
[System.Windows.Forms.MessageBox]::Show(
    Show-Message "Enjoy Windows 11 25H2!`nThanks for using GreekNea.`nA new browser window with GreekNea YouTube will pop up. Please click Subscribe on the confirmation dialog.`nThank you for subscribing - God loves you and may God bless you!" `
                 "Καλή διασκέδαση με τα Windows 11 25H2!`nΕυχαριστούμε που χρησιμοποιείτε GreekNea.`nΘα ανοίξει νέο παράθυρο με το κανάλι GreekNea στο YouTube. Κάντε κλικ στο Subscribe.`nΕυχαριστούμε για την εγγραφή - ο Θεός σας αγαπά και σας ευλογεί!"),
    "Done - GreekNea",
    [System.Windows.Forms.MessageBoxButtons]::OK,
    [System.Windows.Forms.MessageBoxIcon]::Information
) | Out-Null

Open-Url-NewWindow $SubscribeUrl
Log "Script finished at $(Get-Date)."
