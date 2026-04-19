# deploy.ps1 — Stage, commit, push and verify the GitHub Pages deployment.
# Usage: .\deploy.ps1 [-Message "your commit message"]
param(
    [string]$Message = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Repo      = "DAILY19/DustDynasty"
$Branch    = "main"
$PagesUrl  = "https://daily19.github.io/DustDynasty/"

# ── helpers ────────────────────────────────────────────────────────────────
function Write-Step([string]$text) { Write-Host "`n==> $text" -ForegroundColor Cyan }
function Write-Ok([string]$text)   { Write-Host "  OK  $text" -ForegroundColor Green }
function Write-Warn([string]$text) { Write-Host "  !!  $text" -ForegroundColor Yellow }
function Write-Err([string]$text)  { Write-Host " ERR  $text" -ForegroundColor Red }

# ── 1. Sanity checks ───────────────────────────────────────────────────────
Write-Step "Checking tools"
foreach ($tool in @("git", "gh")) {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        Write-Err "$tool not found in PATH. Install it and retry."
        exit 1
    }
}
Write-Ok "git and gh CLI found"

# ── 2. Stage all changes ───────────────────────────────────────────────────
Write-Step "Staging changes"
git add -A
$status = git status --porcelain
if ([string]::IsNullOrWhiteSpace($status)) {
    Write-Warn "Nothing to commit — working tree is clean."
} else {
    if ([string]::IsNullOrWhiteSpace($Message)) {
        # Build an automatic message from what changed
        $changed = git diff --cached --name-only | Select-Object -First 5
        $summary = $changed -join ", "
        if ((git diff --cached --name-only).Count -gt 5) { $summary += ", ..." }
        $Message = "chore: update $summary"
    }
    git commit -m $Message
    Write-Ok "Committed: $Message"
}

# ── 3. Push ────────────────────────────────────────────────────────────────
Write-Step "Pushing to $Branch"
git push origin $Branch
Write-Ok "Pushed"

# ── 4. Check the Actions workflow triggered ────────────────────────────────
Write-Step "Waiting for GitHub Actions export workflow to start"
Start-Sleep -Seconds 5

$runJson = gh run list --repo $Repo --branch $Branch --limit 1 --json databaseId,status,conclusion,createdAt 2>$null
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($runJson)) {
    Write-Warn "gh CLI could not list runs. Check 'gh auth status'."
} else {
    $run = $runJson | ConvertFrom-Json | Select-Object -First 1
    Write-Ok "Latest run #$($run.databaseId) status: $($run.status)"
    Write-Host "  Watching workflow — press Ctrl+C to stop watching early." -ForegroundColor DarkGray

    # Poll until completed (max ~5 min)
    $timeout = 300
    $elapsed = 0
    $interval = 15
    while ($run.status -notin @("completed","failure","cancelled") -and $elapsed -lt $timeout) {
        Start-Sleep -Seconds $interval
        $elapsed += $interval
        $runJson = gh run list --repo $Repo --branch $Branch --limit 1 --json databaseId,status,conclusion 2>$null
        $run = $runJson | ConvertFrom-Json | Select-Object -First 1
        Write-Host "  [$elapsed s] status: $($run.status)" -ForegroundColor DarkGray
    }

    if ($run.conclusion -eq "success") {
        Write-Ok "Workflow completed successfully"
    } elseif ($run.status -eq "completed") {
        Write-Warn "Workflow ended with conclusion: $($run.conclusion)"
        Write-Host "  View logs: https://github.com/$Repo/actions" -ForegroundColor DarkGray
    } else {
        Write-Warn "Workflow still running after ${timeout}s. Check: https://github.com/$Repo/actions"
    }
}

# ── 5. Verify the live site responds ──────────────────────────────────────
Write-Step "Pinging live site"
try {
    $resp = Invoke-WebRequest -Uri $PagesUrl -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
    if ($resp.StatusCode -eq 200) {
        Write-Ok "Site is live and returned HTTP 200: $PagesUrl"
    } else {
        Write-Warn "Site returned HTTP $($resp.StatusCode)"
    }
} catch {
    Write-Warn "Could not reach $PagesUrl — Pages may still be deploying or the URL may differ."
    Write-Host "  Check: https://github.com/$Repo/settings/pages" -ForegroundColor DarkGray
}

# ── 6. Summary ────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host "  Live site : $PagesUrl" -ForegroundColor White
Write-Host "  Actions   : https://github.com/$Repo/actions" -ForegroundColor White
Write-Host "  Repo      : https://github.com/$Repo" -ForegroundColor White
Write-Host "────────────────────────────────────────────────" -ForegroundColor DarkGray
