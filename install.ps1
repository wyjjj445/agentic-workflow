# Agentic Workflow — Install Script (Windows PowerShell)

# Requires PowerShell 5.1+
$ErrorActionPreference = "Stop"

# Ensure .claude directories exist
$claudeDir = "$env:USERPROFILE\.claude"
$skillsDir = "$claudeDir\skills\agentic-flow"
$rulesDir = "$claudeDir\rules"

New-Item -ItemType Directory -Force -Path $skillsDir | Out-Null
New-Item -ItemType Directory -Force -Path $rulesDir | Out-Null

# Determine script location (local vs remote)
$repoBase = "https://raw.githubusercontent.com/wyjjj445/agentic-workflow/main"

function Download-File {
    param($Url, $OutFile)
    try {
        Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing -ErrorAction Stop
        Write-Host "  ✅ Downloaded: $(Split-Path $OutFile -Leaf)" -ForegroundColor Green
    }
    catch {
        Write-Host "  ❌ Failed to download $($Url): $_" -ForegroundColor Red
        throw
    }
}

Write-Host ""
Write-Host "🧠 Agentic Workflow Installer" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Install SKILL.md
Write-Host "📦 Installing skill file..." -ForegroundColor Yellow
$skillPath = Join-Path $skillsDir "SKILL.md"
if (Test-Path ".\SKILL.md") {
    Copy-Item ".\SKILL.md" $skillPath -Force
    Write-Host "  ✅ Copied SKILL.md (local)" -ForegroundColor Green
}
else {
    Download-File -Url "$repoBase/SKILL.md" -OutFile $skillPath
}

# Install RULES.md
Write-Host "📦 Installing rules file..." -ForegroundColor Yellow
$rulesPath = Join-Path $rulesDir "agentic-workflow.md"
if (Test-Path ".\RULES.md") {
    Copy-Item ".\RULES.md" $rulesPath -Force
    Write-Host "  ✅ Copied RULES.md (local)" -ForegroundColor Green
}
else {
    Download-File -Url "$repoBase/RULES.md" -OutFile $rulesPath
}

# Verify
Write-Host ""
Write-Host "🔍 Verifying installation..." -ForegroundColor Yellow
if ((Test-Path $skillPath) -and (Test-Path $rulesPath)) {
    Write-Host ""
    Write-Host "✅ Agentic Workflow installed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "  SKILL.md → $skillPath" -ForegroundColor Gray
    Write-Host "  RULES.md → $rulesPath" -ForegroundColor Gray
    Write-Host ""
    Write-Host "📖 Usage:" -ForegroundColor Cyan
    Write-Host "  Start a new Claude Code session and type:" -ForegroundColor White
    Write-Host "    /agentic-flow <your task>" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "  Or just describe a non-trivial task and Claude will" -ForegroundColor White
    Write-Host "  automatically suggest using agentic workflow." -ForegroundColor White
}
else {
    Write-Host "❌ Installation failed - files missing!" -ForegroundColor Red
    exit 1
}
