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

function Show-Spinner {
    param(
        [scriptblock]$Action,
        [string]$Message = "Processing"
    )

    $spinChars = @('⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏')
    $spinIndex = 0
    $job = Start-Job -ScriptBlock $Action
    
    Write-Host ""
    $cursorTop = [Console]::CursorTop
    $startTime = Get-Date
    
    try {
        while ($job.State -eq 'Running') {
            $elapsed = (Get-Date) - $startTime
            [Console]::SetCursorPosition(0, $cursorTop)
            $spin = $spinChars[$spinIndex % $spinChars.Length]
            $durationText = "($($elapsed.TotalSeconds.ToString('F1'))s)"
            Write-Host "  $spin $Message... $durationText" -NoNewline -ForegroundColor Cyan
            $spinIndex++
            Start-Sleep -Milliseconds 100
        }
        
        $finalElapsed = (Get-Date) - $startTime
        [Console]::SetCursorPosition(0, $cursorTop)
        Write-Host "  ✓ $Message - Complete ($($finalElapsed.TotalSeconds.ToString('F1'))s)" -ForegroundColor Green
        Write-Host ""
        
        $result = Receive-Job -Job $job -Wait
        return $result
    }
    finally {
        Remove-Job -Job $job -Force
    }
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
    
    Write-Host "  Model: $Model" -ForegroundColor Cyan
    Write-Host "  Prompt length: $($prompt.Length) characters" -ForegroundColor Cyan
    Write-Host "  Mode: --yolo (autonomous)" -ForegroundColor Cyan
    Write-Host ""

    $startTime = Get-Date
    
    # Create temp files for output capture
    $stdoutFile = [System.IO.Path]::GetTempFileName()
    $stderrFile = [System.IO.Path]::GetTempFileName()
    
    try {
        $result = Show-Spinner -Message "Running GitHub Copilot CLI" -Action {
            $process = Start-Process -FilePath "copilot" `
                -ArgumentList "--yolo", "--model", $using:Model, "--prompt", $using:prompt `
                -NoNewWindow `
                -Wait `
                -PassThru `
                -RedirectStandardOutput $using:stdoutFile `
                -RedirectStandardError $using:stderrFile
            
            return @{
                ExitCode = $process.ExitCode
                StartTime = $using:startTime
                EndTime = Get-Date
            }
        }
        
        $duration = $result.EndTime - $result.StartTime
        
        # Read output
        $stdout = Get-Content -Path $stdoutFile -Raw -ErrorAction SilentlyContinue
        $stderr = Get-Content -Path $stderrFile -Raw -ErrorAction SilentlyContinue
        
        # Display detailed results
        Write-Host "  Duration: $($duration.TotalSeconds.ToString('F2')) seconds" -ForegroundColor Magenta
        Write-Host "  Exit Code: $($result.ExitCode)" -ForegroundColor $(if ($result.ExitCode -eq 0) { 'Green' } else { 'Red' })
        
        if ($stdout -and $stdout.Trim()) {
            Write-Host ""
            Write-Host "  Output:" -ForegroundColor White
            Write-Host "  " + ("-" * 60) -ForegroundColor DarkGray
            $stdout.Split("`n") | ForEach-Object {
                if ($_.Trim()) {
                    Write-Host "  $_" -ForegroundColor Gray
                }
            }
            Write-Host "  " + ("-" * 60) -ForegroundColor DarkGray
        }
        
        if ($stderr -and $stderr.Trim()) {
            Write-Host ""
            Write-Host "  Errors/Warnings:" -ForegroundColor Yellow
            Write-Host "  " + ("-" * 60) -ForegroundColor DarkGray
            $stderr.Split("`n") | ForEach-Object {
                if ($_.Trim()) {
                    Write-Host "  $_" -ForegroundColor Red
                }
            }
            Write-Host "  " + ("-" * 60) -ForegroundColor DarkGray
        }
        
        if ($result.ExitCode -ne 0) {
            Write-Host ""
            Write-Host "  Copilot CLI exited with error code $($result.ExitCode)" -ForegroundColor Red
            return $false
        }
        
        Write-Host ""
        return $true
    }
    finally {
        # Cleanup temp files
        Remove-Item -Path $stdoutFile -ErrorAction SilentlyContinue
        Remove-Item -Path $stderrFile -ErrorAction SilentlyContinue
    }
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
