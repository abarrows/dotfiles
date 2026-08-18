# local-ai-setup.ps1 — Retail Success AI bootstrap (public loader, Windows).
#
# Lives in abarrows/dotfiles: onboarding_bin/local-ai-setup.ps1 (branch: production).
# Run from an *elevated* PowerShell (right-click -> Run as administrator):
#   irm https://raw.githubusercontent.com/abarrows/dotfiles/production/onboarding_bin/local-ai-setup.ps1 | iex
#
# Windows counterpart of local-ai-setup.sh (same directory). Thin by design:
# installs the apps via Chocolatey and the Retail Success plugin, then hands
# off to the setup script that ships INSIDE the plugin (rides plugin
# autoUpdate). Standalone (irm-able): no repo-relative paths. Idempotent
# throughout — safe to re-run on a fresh, partial, or healthy machine.
# Compatible with Windows PowerShell 5.1 and PowerShell 7+.

$ErrorActionPreference = 'Continue'
$script:Failures = 0

function Step([string]$m) { Write-Host "`n==> $m" -ForegroundColor White }
function Ok([string]$m)   { Write-Host "  [ok] $m" -ForegroundColor Green }
function Warn([string]$m) { Write-Host "  [!!] $m" -ForegroundColor Yellow }
function Soft([string]$m) { Warn $m; $script:Failures++ }
function Die([string]$m)  { Write-Host "`n  [xx] $m" -ForegroundColor Red; exit 1 }

# Re-read PATH after installers touch it (choco/installers edit the registry,
# not this session).
function Update-SessionPath {
  $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
              [Environment]::GetEnvironmentVariable('Path', 'User')
}

# =============================================================== 1. guards ===
Step "Checking this machine"

if ($env:OS -ne 'Windows_NT') {
  Die "Windows only. On macOS run:  /bin/bash -c `"`$(curl -fsSL https://raw.githubusercontent.com/abarrows/dotfiles/production/onboarding_bin/local-ai-setup.sh)`""
}
Ok "Windows"

$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Die "This PowerShell is not elevated, and Chocolatey installs need admin rights.`n    -> Right-click PowerShell -> 'Run as administrator', then re-run the one-liner (safe to run twice)."
}
Ok "elevated PowerShell"

# Floor pinned at Win10 2004 (build 19041) — WSL2 + Docker Desktop requirement.
# Override: $env:RS_AI_SETUP_MIN_BUILD = 17763 before running.
$minBuild = 19041
if ($env:RS_AI_SETUP_MIN_BUILD) { $minBuild = [int]$env:RS_AI_SETUP_MIN_BUILD }
$build = [Environment]::OSVersion.Version.Build
if ($build -lt $minBuild) {
  Die "Windows build $build too old (need >= $minBuild). Update via Settings -> Windows Update, then re-run."
}
Ok ("Windows build {0}" -f $build)

[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
$net = Test-NetConnection raw.githubusercontent.com -Port 443 -InformationLevel Quiet -WarningAction SilentlyContinue
if (-not $net) { Die "Can't reach github. Check network/VPN and re-run." }
Ok "network reachable"

# =========================================================== 2. chocolatey ===
Step "Chocolatey"
if (Get-Command choco -ErrorAction SilentlyContinue) {
  Ok ("{0} (present)" -f (choco --version))
} else {
  Set-ExecutionPolicy Bypass -Scope Process -Force
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
  Update-SessionPath
  if (-not (Get-Command choco -ErrorAction SilentlyContinue)) { Die "Chocolatey install failed." }
  Ok "Chocolatey installed"
}

# ============================================================= 3. installs ===
Step "Apps (only what's missing — choco install no-ops when present)"
# Package ids verified against community.chocolatey.org. 'claude' is the
# Anthropic desktop app (project url: claude.ai/download). git is required by
# Claude Code on Windows (Git Bash powers its Bash tool).
function Install-ChocoPkg([string]$Id) {
  choco install $Id -y --no-progress --limit-output | Out-Null
  if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq 1641 -or $LASTEXITCODE -eq 3010) {
    if ($LASTEXITCODE -eq 3010) { Warn "$Id installed — reboot required to finish" } else { Ok $Id }
  } else {
    Soft "$Id failed to install (choco exit $LASTEXITCODE)"
  }
}
Install-ChocoPkg git
Install-ChocoPkg gh
Install-ChocoPkg claude          # desktop app
Install-ChocoPkg docker-desktop
Install-ChocoPkg warp
Install-ChocoPkg vscode
Update-SessionPath

Step "Claude Code CLI (official native installer — auto-updates itself)"
if (Get-Command claude -ErrorAction SilentlyContinue) {
  Ok "claude (present)"
} else {
  try {
    Invoke-RestMethod https://claude.ai/install.ps1 | Invoke-Expression
  } catch {
    Soft "Claude Code installer threw: $($_.Exception.Message)"
  }
  Update-SessionPath
  if (Get-Command claude -ErrorAction SilentlyContinue) { Ok "claude installed" }
  else { Die "claude CLI missing after install — open a NEW PowerShell window and re-run the one-liner." }
}

Step "VS Code Claude extension"
$code = Get-Command code -ErrorAction SilentlyContinue
if (-not $code) {
  $codeCmd = Join-Path $env:ProgramFiles 'Microsoft VS Code\bin\code.cmd'
  if (Test-Path $codeCmd) { $code = $codeCmd }
}
if ($code) {
  $codeExe = if ($code -is [string]) { $code } else { $code.Source }
  $ext = & $codeExe --list-extensions 2>$null
  if ($ext -match '^anthropic\.claude-code$') {
    Ok "VS Code Claude extension (present)"
  } else {
    & $codeExe --install-extension anthropic.claude-code | Out-Null
    if ($LASTEXITCODE -eq 0) { Ok "VS Code Claude extension installed" }
    else { Soft "VS Code extension install failed — install 'Claude Code' from the marketplace manually" }
  }
} else {
  Warn "code CLI not found — open VS Code once, then re-run"
}

# =============================================================== 4. gates ====
Step "GitHub auth"
gh auth status *> $null
if ($LASTEXITCODE -eq 0) { Ok "gh authenticated" }
else {
  Write-Host "  Opening GitHub login (choose HTTPS + browser)..."
  gh auth login
  if ($LASTEXITCODE -ne 0) { Die "GitHub auth is required for the private plugin repo. Re-run after 'gh auth login' succeeds." }
}

Step "Docker Desktop + MCP Toolkit"
wsl --status *> $null
if ($LASTEXITCODE -ne 0) {
  Warn "WSL2 not detected — Docker Desktop requires it. Enabling (may need a reboot)..."
  wsl --install --no-distribution *> $null
  if ($LASTEXITCODE -eq 0) { Warn "WSL enabled. If Docker fails below, REBOOT and re-run this one-liner." }
  else { Warn "Could not enable WSL automatically — run 'wsl --install --no-distribution' in an admin PowerShell, reboot, re-run." }
}
docker info *> $null
if ($LASTEXITCODE -ne 0) {
  $dockerExe = Join-Path $env:ProgramFiles 'Docker\Docker\Docker Desktop.exe'
  if (Test-Path $dockerExe) { Start-Process $dockerExe } else { Die "Docker Desktop not found — install failed above; fix and re-run." }
  Write-Host "  Waiting for the Docker daemon (accept the first-run dialogs)..."
  for ($i = 0; $i -lt 60; $i++) {
    docker info *> $null
    if ($LASTEXITCODE -eq 0) { break }
    Start-Sleep -Seconds 3
  }
  docker info *> $null
  if ($LASTEXITCODE -ne 0) { Die "Docker daemon never came up. Finish Docker Desktop first-run setup (and reboot if WSL was just enabled), then re-run." }
}
Ok "docker daemon running"
docker mcp --help *> $null
if ($LASTEXITCODE -ne 0) { Die "'docker mcp' unavailable — update Docker Desktop (>= 4.42) / enable the MCP Toolkit, then re-run." }
Ok "MCP Toolkit available"

# ============================================================== 5. plugin ====
Step "Retail Success Claude plugin"
# CLAUDECODE='' : the plugin CLI refuses to run nested inside a Claude session.
$env:CLAUDECODE = ''
claude plugin marketplace add Retail-Success/Wayroo.tools *> $null   # idempotent: errors if present
claude plugin install rs-agents@retailsuccess *> $null
if ($LASTEXITCODE -eq 0) { Ok "rs-agents@retailsuccess" }
else {
  claude plugin install rs-agents@wayroo *> $null
  if ($LASTEXITCODE -eq 0) { Ok "rs-agents@wayroo (fallback marketplace name)" }
  elseif ((claude plugin list 2>$null) -match 'rs-agents') { Ok "rs-agents already installed" }
  else { Die "Could not install the rs-agents plugin. Run 'claude plugin marketplace add Retail-Success/Wayroo.tools' then 'claude plugin install rs-agents@retailsuccess' manually." }
}

# ============================================================= 6. handoff ====
Step "Handing off to the plugin's setup script (MCP wiring + settings)"
# Name-agnostic scan of the plugin cache — layout varies across CLI versions.
$pluginRoot = Join-Path $HOME '.claude\plugins'
$setupPs1 = Get-ChildItem -Path $pluginRoot -Recurse -Filter 'setup.ps1' -ErrorAction SilentlyContinue |
  Where-Object { $_.FullName -like '*skills*local-ai-setup*' } |
  Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($setupPs1) {
  Ok ("found {0}" -f $setupPs1.FullName)
  & $setupPs1.FullName
  if ($LASTEXITCODE -ne 0) { Warn "setup.ps1 reported issues — see output above; re-run any time with: & `"$($setupPs1.FullName)`"" }
} else {
  # Older plugin versions ship only the bash setup.sh — run it via Git Bash.
  $setupSh = Get-ChildItem -Path $pluginRoot -Recurse -Filter 'setup.sh' -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -like '*skills*local-ai-setup*' } |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
  $bash = Join-Path $env:ProgramFiles 'Git\bin\bash.exe'
  if ($setupSh -and (Test-Path $bash)) {
    Ok ("found {0} (running via Git Bash)" -f $setupSh.FullName)
    & $bash $setupSh.FullName
    if ($LASTEXITCODE -ne 0) { Warn "setup.sh reported issues — see output above" }
  } else {
    Warn "Could not locate the plugin's setup script in ~\.claude\plugins."
    Warn "Recovery: open a terminal, run 'claude', then type /local-ai-setup — the skill will locate and run its own setup script."
  }
}

# ============================================================= 7. wrap-up ====
Step "Final check"
claude doctor
if ($LASTEXITCODE -ne 0) { Warn "claude doctor reported problems (see above)" }
Write-Host @"

  -- Done ------------------------------------------------------------------
  Installed/verified: Claude desktop, Claude Code (CLI + VS Code), Docker
  Desktop (MCP Toolkit), Warp, VS Code, git, gh, rs-agents plugin.
  Next: open Warp (or Windows Terminal), cd into any repo, run: claude
  then try /local-ai-setup for the guided tour.
  Re-run this one-liner any time; it only fixes gaps.
"@
if ($script:Failures -gt 0) { Warn "$($script:Failures) step(s) need attention (see [!!] above)."; exit 1 }
Ok "All steps clean."
