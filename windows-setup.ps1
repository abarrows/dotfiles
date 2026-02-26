<#
.SYNOPSIS
    Windows machine provisioning script - equivalent of Brewfile.base for macOS.

.DESCRIPTION
    Provisions a new Windows machine for software engineering onboarding.
    Reads package IDs from Wingetfile.base and installs them via winget.
    Handles winget bootstrap, font installation guidance, and post-install steps.

.EXAMPLE
    # Run from an elevated PowerShell prompt:
    Set-ExecutionPolicy Bypass -Scope Process -Force
    .\windows-setup.ps1

.NOTES
    Prerequisites (manual, one-time):
      1. Windows 10 1809+ or Windows 11
      2. winget (App Installer) - available from the Microsoft Store or:
         https://github.com/microsoft/winget-cli/releases
      3. No need to manually run as Administrator - the script self-elevates.
#>

# ── Self-elevation ─────────────────────────────────────────────────────────────
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Restarting as Administrator..." -ForegroundColor Yellow
    $ps = if (Get-Command pwsh -ErrorAction SilentlyContinue) { "pwsh" } else { "powershell" }
    Start-Process $ps -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"   # Log failures but keep going, matching brew bundle behavior

$ScriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$Wingetfile = Join-Path $ScriptDir "Wingetfile.base"

# ── Helpers ────────────────────────────────────────────────────────────────────

function Write-Step  { param([string]$Msg) Write-Host "`n==> $Msg" -ForegroundColor Cyan }
function Write-Ok    { param([string]$Msg) Write-Host "  [OK]  $Msg" -ForegroundColor Green }
function Write-Skip  { param([string]$Msg) Write-Host "  [--]  $Msg" -ForegroundColor DarkGray }
function Write-Fail  { param([string]$Msg) Write-Host "  [!!]  $Msg" -ForegroundColor Red }
function Write-Note  { param([string]$Msg) Write-Host "  [**]  $Msg" -ForegroundColor Yellow }

# ── 1. Verify winget is available ──────────────────────────────────────────────

Write-Step "Checking winget availability"
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Fail "winget is not installed."
    Write-Note "Install 'App Installer' from the Microsoft Store, or download from:"
    Write-Note "https://github.com/microsoft/winget-cli/releases"
    exit 1
}
$wingetVersion = (winget --version)
Write-Ok "winget $wingetVersion found."

# ── 2. Accept Microsoft Store agreements (non-interactive) ────────────────────

Write-Step "Accepting winget source agreements"
winget source update --disable-interactivity | Out-Null

# ── 3. Parse Wingetfile.base ───────────────────────────────────────────────────

Write-Step "Reading $Wingetfile"
if (-not (Test-Path $Wingetfile)) {
    Write-Fail "Wingetfile.base not found at: $Wingetfile"
    exit 1
}

$packages = [System.Collections.Generic.List[string]]::new()

foreach ($line in Get-Content $Wingetfile) {
    $trimmed = $line.Trim()

    # Skip blank lines and full-line comments
    if ([string]::IsNullOrWhiteSpace($trimmed) -or $trimmed.StartsWith("#")) {
        continue
    }

    # Strip inline comment, grab the first token (the package ID)
    $packageId = ($trimmed -split "#")[0].Trim()
    if (-not [string]::IsNullOrWhiteSpace($packageId)) {
        $packages.Add($packageId)
    }
}

Write-Ok "$($packages.Count) packages queued for installation."

# ── 4. Install packages ────────────────────────────────────────────────────────

Write-Step "Installing packages"

$succeeded = 0
$skipped   = 0
$failed    = 0
$failedPkgs = [System.Collections.Generic.List[string]]::new()

foreach ($pkg in $packages) {
    # Check if already installed (fast path)
    $installed = winget list --id $pkg --exact --disable-interactivity 2>&1 |
                 Select-String $pkg
    if ($installed) {
        Write-Skip "$pkg (already installed)"
        $skipped++
        continue
    }

    Write-Host "  Installing $pkg ..." -NoNewline
    $result = winget install --id $pkg --exact --silent --accept-package-agreements --accept-source-agreements 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host " done" -ForegroundColor Green
        $succeeded++
    } else {
        Write-Host " FAILED" -ForegroundColor Red
        Write-Fail "  winget exit code $LASTEXITCODE for $pkg"
        $failedPkgs.Add($pkg)
        $failed++
    }
}

# ── 5. Post-install: pipx ──────────────────────────────────────────────────────

Write-Step "Post-install: pipx"
if (Get-Command python -ErrorAction SilentlyContinue) {
    Write-Host "  Installing pipx via pip..." -NoNewline
    python -m pip install --user pipx 2>&1 | Out-Null
    python -m pipx ensurepath 2>&1 | Out-Null
    Write-Host " done" -ForegroundColor Green
} else {
    Write-Note "Python not found in PATH yet. Re-open your terminal and run:"
    Write-Note "  python -m pip install --user pipx && python -m pipx ensurepath"
}

# ── 6. Post-install: dotenv-linter via cargo ───────────────────────────────────

Write-Step "Post-install: dotenv-linter (requires Rust/cargo)"
if (Get-Command cargo -ErrorAction SilentlyContinue) {
    Write-Host "  cargo install dotenv-linter..." -NoNewline
    cargo install dotenv-linter 2>&1 | Out-Null
    Write-Host " done" -ForegroundColor Green
} else {
    Write-Note "cargo not found. Install Rust from https://rustup.rs/ then run:"
    Write-Note "  cargo install dotenv-linter"
}

# ── 7. Post-install: Nerd Fonts guidance ──────────────────────────────────────

Write-Step "Fonts (manual step)"
Write-Note "Nerd Fonts (FiraCode NF + Noto Color Emoji) are not available via winget."
Write-Note "Option A - Scoop (recommended):"
Write-Note "  irm get.scoop.sh | iex"
Write-Note "  scoop bucket add nerd-fonts"
Write-Note "  scoop install FiraCode-NF Noto-NF"
Write-Note "Option B - Manual download:"
Write-Note "  https://www.nerdfonts.com/font-downloads"

# ── 8. Post-install: OhMyPosh shell profile ───────────────────────────────────

Write-Step "Shell prompt (Oh My Posh)"
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    if (-not (Test-Path $PROFILE)) {
        New-Item -ItemType File -Path $PROFILE -Force | Out-Null
    }
    if (-not (Select-String -Path $PROFILE -Pattern "oh-my-posh" -Quiet)) {
        Add-Content -Path $PROFILE "`noh-my-posh init pwsh | Invoke-Expression"
        Write-Ok "Added Oh My Posh init to $PROFILE"
    } else {
        Write-Skip "Oh My Posh already configured in PowerShell profile."
    }
} else {
    Write-Note "Oh My Posh not in PATH yet. Re-open your terminal to activate it."
}

# ── 9. Post-install: Git GPG signing reminder ─────────────────────────────────

Write-Step "Git commit signing (GPG)"
Write-Note "After Gpg4win is installed, configure signed commits:"
Write-Note "  gpg --full-generate-key"
Write-Note "  gpg --list-secret-keys --keyid-format=long"
Write-Note "  git config --global user.signingkey <YOUR_KEY_ID>"
Write-Note "  git config --global commit.gpgsign true"
Write-Note "  git config --global gpg.program `"C:\Program Files (x86)\GnuPG\bin\gpg.exe`""
Write-Note "Then upload your public key to GitHub: https://github.com/settings/keys"

# ── 10. Summary ────────────────────────────────────────────────────────────────

Write-Step "Summary"
Write-Ok  "Installed : $succeeded"
Write-Skip "Skipped   : $skipped (already present)"
if ($failed -gt 0) {
    Write-Fail "Failed    : $failed"
    Write-Host "`n  The following packages failed to install:" -ForegroundColor Red
    $failedPkgs | ForEach-Object { Write-Host "    - $_" -ForegroundColor Red }
    Write-Note "Re-run the script or install manually with: winget install --id <PackageId>"
}

Write-Host "`nProvisioning complete. Restart your terminal to pick up all PATH changes.`n" -ForegroundColor Cyan
