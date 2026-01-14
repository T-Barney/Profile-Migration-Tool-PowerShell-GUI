<#
.SYNOPSIS
    GUI-based User Profile Migration Tool.

.DESCRIPTION
    This script provides a Windows Forms GUI to wrap Robocopy functionality.
    It allows IT administrators to migrate user data between computers using
    administrative shares (C$) over the network.
    
    Features:
    - Auto-elevation to Administrator.
    - Robocopy multi-threading (/MT:32).
    - Excludes system folders and AppData to prevent profile corruption.
    - Generates detailed logs on the Desktop.

.NOTES
    Author:  Barnabas Tanczos
    Created: 12/19/2025
    Version: 2.0
#>

# ----------------------------
# ASKING FOR ADMIN PERMISSIONS
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
	Write-Host "Asking for elevated credentials..." -ForegroundColor Yellow
    Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Exit
}
# ----------------------------

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# GUI SETUP
$form = New-Object System.Windows.Forms.Form
$form.Text = "Profile Migrator Tool"
$form.Size = New-Object System.Drawing.Size(400, 300)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

# Label: Username
$lblUser = New-Object System.Windows.Forms.Label
$lblUser.Location = New-Object System.Drawing.Point(20, 20)
$lblUser.Size = New-Object System.Drawing.Size(340, 20)
$lblUser.Text = "Username to Copy:"
$form.Controls.Add($lblUser)

# TextBox: Username
$txtUser = New-Object System.Windows.Forms.TextBox
$txtUser.Location = New-Object System.Drawing.Point(20, 40)
$txtUser.Size = New-Object System.Drawing.Size(340, 20)
$form.Controls.Add($txtUser)

# Label: Source
$lblSource = New-Object System.Windows.Forms.Label
$lblSource.Location = New-Object System.Drawing.Point(20, 80)
$lblSource.Size = New-Object System.Drawing.Size(340, 20)
$lblSource.Text = "Source Service Tag:"
$form.Controls.Add($lblSource)

# TextBox: Source
$txtSource = New-Object System.Windows.Forms.TextBox
$txtSource.Location = New-Object System.Drawing.Point(20, 100)
$txtSource.Size = New-Object System.Drawing.Size(340, 20)
$form.Controls.Add($txtSource)

# Label: Destination
$lblDest = New-Object System.Windows.Forms.Label
$lblDest.Location = New-Object System.Drawing.Point(20, 140)
$lblDest.Size = New-Object System.Drawing.Size(340, 20)
$lblDest.Text = "Destination Service Tag:"
$form.Controls.Add($lblDest)

# TextBox: Destination
$txtDest = New-Object System.Windows.Forms.TextBox
$txtDest.Location = New-Object System.Drawing.Point(20, 160)
$txtDest.Size = New-Object System.Drawing.Size(340, 20)
$form.Controls.Add($txtDest)

# Button: Start
$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Location = New-Object System.Drawing.Point(20, 200)
$btnRun.Size = New-Object System.Drawing.Size(340, 40)
$btnRun.Text = "START MIGRATION"
$btnRun.BackColor = "LightBlue"
$form.Controls.Add($btnRun)

# LOGIC
$btnRun.Add_Click({
    $srcTag = $txtSource.Text.Trim()
    $dstTag = $txtDest.Text.Trim()
    $user   = $txtUser.Text.Trim()

    # Validation
    if ($srcTag -eq "" -or $dstTag -eq "" -or $user -eq "") {
        [System.Windows.Forms.MessageBox]::Show("Please fill in all fields.", "Error", "OK", "Error")
        return
    }

    # Construct paths
    $sourcePath = "\\$srcTag\c$\Users\$user"
    $destPath   = "\\$dstTag\c$\Users\$user"
	
	if (!(Test-Path $sourcePath)) {
        [System.Windows.Forms.MessageBox]::Show("Cannot find the source folder!`n`nTried to access: $sourcePath`n`nMake sure the Service Tag is correct and the computer is online.", "Path Error", "OK", "Error")
        return
    }

	# LOGGING
    # This creates a folder on your Desktop called "Migration_Logs"
    $logDir = "$env:USERPROFILE\Desktop\Migration_Logs"
    if (!(Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir
    }
    
    # It's going to look like this: "user_date-time.log"
    $timestamp = Get-Date -Format "yyyyMMdd-HHmm"
    $logFile   = "$logDir\$user`_$timestamp.log"

    # Construct robocopy arguments
	# ---------- Add any specific software folders to exclude here ----------
    $roboArgs = "`"$sourcePath`" `"$destPath`" /E /ZB /COPY:DAT /R:1 /W:1 /MT:32 /XJ /XD `"OneDrive*`" `"3D Objects`" `"Tracing`" `"Appdata`" `"diag`" `"product`" /XF NTUSER.DAT* /LOG:`"$logFile`" /TEE"

    # Confirmation
    $confirm = [System.Windows.Forms.MessageBox]::Show("Copy from: $sourcePath `n`n To: $destPath `n", "Confirm copy", "YesNo", "Question")
    
    if ($confirm -eq "Yes") {
        # Start cmd with robocopy command
        # /k keeps the window open
        Start-Process "cmd.exe" -ArgumentList "/k robocopy $roboArgs"
    }
})

$form.ShowDialog()