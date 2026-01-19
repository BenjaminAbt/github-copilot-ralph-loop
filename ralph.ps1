[CmdletBinding()]
param(
    [int]$MaxIterations = 10,
    [int]$TimeoutSeconds = 600
)

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptRoot

# $Model = "gpt-5-mini"
$Model = "gpt-5.1-codex-mini"

$ProgressFile = Join-Path $scriptRoot "ralph\state\progress.txt"
$PrdFile = Join-Path $scriptRoot "ralph\prd.json"
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
        [string]$PrdFile,
        [string]$PromptFile
    )

    if (-not (Test-Path $PrdFile)) {
        Write-Host "Error: PRD file not found: $PrdFile" -ForegroundColor Red
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
        [string]$PromptFile,
        [int]$TimeoutSeconds
    )

    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
    Write-Host "Starting iteration $Iteration of $MaxIterations" -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

    Update-Iteration -ProgressFile $ProgressFile -Iteration $Iteration

    $prompt = Get-Content -Path $PromptFile -Raw
    
    Write-Host "  Model: $Model" -ForegroundColor Cyan
    Write-Host "  Prompt length: $($prompt.Length) characters" -ForegroundColor Cyan
    Write-Host "  Mode: --yolo (autonomous)" -ForegroundColor Cyan
    Write-Host "  Timeout: $TimeoutSeconds seconds" -ForegroundColor Cyan
    Write-Host ""

    $startTime = Get-Date
    
    try {
        # Start process with output capture
        $processInfo = New-Object System.Diagnostics.ProcessStartInfo
        $processInfo.FileName = "copilot"
        # Use ArgumentList to properly handle arguments with spaces
        $processInfo.ArgumentList.Add("--yolo")
        $processInfo.ArgumentList.Add("--model")
        $processInfo.ArgumentList.Add($Model)
        $processInfo.ArgumentList.Add("--prompt")
        $processInfo.ArgumentList.Add($prompt)
        $processInfo.UseShellExecute = $false
        $processInfo.CreateNoWindow = $true
        $processInfo.RedirectStandardOutput = $true
        $processInfo.RedirectStandardError = $true
        
        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $processInfo
        
        # String builders for output capture
        $stdoutBuilder = New-Object System.Text.StringBuilder
        $stderrBuilder = New-Object System.Text.StringBuilder
        
        # Event handlers for async output reading
        $stdoutEvent = Register-ObjectEvent -InputObject $process -EventName OutputDataReceived -Action {
            if ($EventArgs.Data) {
                $null = $Event.MessageData.AppendLine($EventArgs.Data)
            }
        } -MessageData $stdoutBuilder
        
        $stderrEvent = Register-ObjectEvent -InputObject $process -EventName ErrorDataReceived -Action {
            if ($EventArgs.Data) {
                $null = $Event.MessageData.AppendLine($EventArgs.Data)
            }
        } -MessageData $stderrBuilder
        
        Write-Host "  ⠋ Running GitHub Copilot CLI..." -ForegroundColor Cyan
        $cursorTop = [Console]::CursorTop - 1
        
        $null = $process.Start()
        $process.BeginOutputReadLine()
        $process.BeginErrorReadLine()
        
        $spinChars = @('⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏')
        $spinIndex = 0
        
        # Monitor process with timeout
        while (-not $process.HasExited) {
            $elapsed = (Get-Date) - $startTime
            
            if ($elapsed.TotalSeconds -gt $TimeoutSeconds) {
                Write-Host ""
                Write-Host "  ⚠ Timeout after $TimeoutSeconds seconds - killing process" -ForegroundColor Red
                $process.Kill($true)
                $process.WaitForExit(5000)
                return $false
            }
            
            [Console]::SetCursorPosition(0, $cursorTop)
            $spin = $spinChars[$spinIndex % $spinChars.Length]
            $durationText = "($($elapsed.TotalSeconds.ToString('F1'))s)"
            Write-Host "  $spin Running GitHub Copilot CLI... $durationText" -NoNewline -ForegroundColor Cyan
            $spinIndex++
            
            Start-Sleep -Milliseconds 100
        }
        
        $endTime = Get-Date
        $duration = $endTime - $startTime
        
        # Wait for output to be fully captured
        Start-Sleep -Milliseconds 200
        
        [Console]::SetCursorPosition(0, $cursorTop)
        Write-Host "  ✓ Running GitHub Copilot CLI - Complete ($($duration.TotalSeconds.ToString('F1'))s)" -ForegroundColor Green
        Write-Host ""
        
        # Unregister events
        Unregister-Event -SourceIdentifier $stdoutEvent.Name -ErrorAction SilentlyContinue
        Unregister-Event -SourceIdentifier $stderrEvent.Name -ErrorAction SilentlyContinue
        
        # Get captured output
        $stdout = $stdoutBuilder.ToString()
        $stderr = $stderrBuilder.ToString()
        
        # Display results
        Write-Host "  Duration: $($duration.TotalSeconds.ToString('F2')) seconds" -ForegroundColor Magenta
        Write-Host "  Exit Code: $($process.ExitCode)" -ForegroundColor $(if ($process.ExitCode -eq 0) { 'Green' } else { 'Red' })
        
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
            # Show as Info when successful, as Errors when failed
            if ($process.ExitCode -eq 0) {
                Write-Host "  Status/Info:" -ForegroundColor Cyan
                Write-Host "  " + ("-" * 60) -ForegroundColor DarkGray
                $stderr.Split("`n") | ForEach-Object {
                    if ($_.Trim()) {
                        Write-Host "  $_" -ForegroundColor DarkGray
                    }
                }
            } else {
                Write-Host "  Errors/Warnings:" -ForegroundColor Yellow
                Write-Host "  " + ("-" * 60) -ForegroundColor DarkGray
                $stderr.Split("`n") | ForEach-Object {
                    if ($_.Trim()) {
                        Write-Host "  $_" -ForegroundColor Red
                    }
                }
            }
            Write-Host "  " + ("-" * 60) -ForegroundColor DarkGray
        }
        
        if ($process.ExitCode -ne 0) {
            Write-Host ""
            Write-Host "  ⚠ Copilot CLI exited with error code $($process.ExitCode)" -ForegroundColor Red
            return $false
        }
        
        Write-Host ""
        return $true
    }
    catch {
        Write-Host ""
        Write-Host "  ✗ Error running Copilot CLI: $_" -ForegroundColor Red
        if ($process -and -not $process.HasExited) {
            $process.Kill($true)
        }
        return $false
    }
    finally {
        # Cleanup events
        if ($stdoutEvent) {
            Unregister-Event -SourceIdentifier $stdoutEvent.Name -ErrorAction SilentlyContinue
        }
        if ($stderrEvent) {
            Unregister-Event -SourceIdentifier $stderrEvent.Name -ErrorAction SilentlyContinue
        }
        if ($process) {
            $process.Dispose()
        }
    }
}

$null = Register-EngineEvent -SourceIdentifier ConsoleCancelEvent -Action {
    Write-Host "`nInterrupted. Progress saved in $ProgressFile" -ForegroundColor Yellow
    exit 130
}

Write-Banner
Ensure-RequiredFiles -PrdFile $PrdFile -PromptFile $PromptFile
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

    if (-not (Run-Iteration -Iteration $iteration -MaxIterations $MaxIterations -ProgressFile $ProgressFile -PromptFile $PromptFile -TimeoutSeconds $TimeoutSeconds)) {
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
