[CmdletBinding()]
param(
    [int]$MaxIterations = 10
)

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptRoot

$Model = "gpt-5-mini"
# $Model = "gpt-5.1-codex-mini"

$ProgressFile = Join-Path $scriptRoot "ralph\state\progress.txt"
$PrdsPath = Join-Path $scriptRoot "ralph\prds"
$PromptFile = Join-Path $scriptRoot "ralph\prompt.md"

function Write-Banner {
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Blue
    Write-Host "║           Ralph Wiggum Method - Autonomous Loop               ║" -ForegroundColor Blue
    Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Blue
    Write-Host ""
}

function Ensure-RequiredFiles {
    param(
        [string]$PrdsPath,
        [string]$PromptFile
    )

    if (-not (Test-Path $PrdsPath)) {
        Write-Host "Error: PRDs folder not found: $PrdsPath" -ForegroundColor Red
        exit 1
    }

    $prdFiles = Get-ChildItem -Path $PrdsPath -Filter "*.md" -File
    if ($prdFiles.Count -eq 0) {
        Write-Host "Error: No PRD files found in $PrdsPath" -ForegroundColor Red
        exit 1
    }

    if (-not (Test-Path $PromptFile)) {
        Write-Host "Error: Prompt file not found: $PromptFile" -ForegroundColor Red
        exit 1
    }
}

function Initialize-ProgressFile {
    param([string]$ProgressFile)

    $progressDir = Split-Path -Parent $ProgressFile
    if (-not (Test-Path $progressDir)) {
        New-Item -Path $progressDir -ItemType Directory | Out-Null
    }

    if (-not (Test-Path $ProgressFile)) {
        @(
            "iteration: 0",
            "status: not_started",
            "current_story: none",
            "completed_stories: []"
        ) | Set-Content -Path $ProgressFile -Encoding UTF8
    }
}

function Get-Iteration {
    param([string]$ProgressFile)

    $line = Select-String -Path $ProgressFile -Pattern '^iteration:' | Select-Object -First 1
    if (-not $line) {
        return 0
    }

    return [int]($line.Line -replace 'iteration:\s*', '')
}

function Check-Completion {
    param([string]$ProgressFile)

    $line = Select-String -Path $ProgressFile -Pattern '^status:' | Select-Object -First 1
    if (-not $line) {
        return $false
    }

    $status = ($line.Line -replace 'status:\s*', '').Trim()
    return $status -eq 'complete'
}

function Update-Iteration {
    param(
        [string]$ProgressFile,
        [int]$Iteration
    )

    $content = Get-Content -Path $ProgressFile
    $content = $content | ForEach-Object {
        if ($_ -match '^iteration:') { "iteration: $Iteration" } else { $_ }
    }

    $content | Set-Content -Path $ProgressFile -Encoding UTF8
}

function Run-Iteration {
    param(
        [int]$Iteration,
        [int]$MaxIterations,
        [string]$ProgressFile,
        [string]$PromptFile
    )

    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
    Write-Host "Starting iteration $Iteration of $MaxIterations" -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

    Update-Iteration -ProgressFile $ProgressFile -Iteration $Iteration

    $prompt = Get-Content -Path $PromptFile -Raw

    copilot --yolo --model $Model --prompt "$prompt"

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Copilot CLI exited with error code $LASTEXITCODE" -ForegroundColor Red
        return $false
    }

    return $true
}

$null = Register-EngineEvent -SourceIdentifier ConsoleCancelEvent -Action {
    Write-Host "`nInterrupted. Progress saved in $ProgressFile" -ForegroundColor Yellow
    exit 130
}

Write-Banner
Ensure-RequiredFiles -PrdsPath $PrdsPath -PromptFile $PromptFile
Initialize-ProgressFile -ProgressFile $ProgressFile

$iteration = (Get-Iteration -ProgressFile $ProgressFile) + 1

while ($iteration -le $MaxIterations) {
    if (Check-Completion -ProgressFile $ProgressFile) {
        Write-Host "" -ForegroundColor Green
        Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
        Write-Host "║              All stories complete! Great success!             ║" -ForegroundColor Green
        Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
        Write-Host "" -ForegroundColor Green
        exit 0
    }

    if (-not (Run-Iteration -Iteration $iteration -MaxIterations $MaxIterations -ProgressFile $ProgressFile -PromptFile $PromptFile)) {
        Write-Host "Iteration $iteration failed. Check logs and retry." -ForegroundColor Red
        exit 1
    }

    $iteration++
    Start-Sleep -Seconds 2
}

Write-Host "" -ForegroundColor Yellow
Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "║     Max iterations reached. Review progress and continue.    ║" -ForegroundColor Yellow
Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
Write-Host "" -ForegroundColor Yellow
