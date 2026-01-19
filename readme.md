# Ralph Loop Sample with GitHub Copilot CLI

> Autonomous coding loop demonstration using the **Ralph Wiggum Method** with GitHub Copilot CLI

## Table of Contents

- [What is Ralph Wiggum?](#what-is-ralph-wiggum)
- [Quick Start](#quick-start)
- [Sample Files Generated](#sample-files-generated)
- [Sample Console Output](#sample-console-output)
- [Configuration](#configuration)

## What is Ralph Wiggum?

The **Ralph Wiggum Method** is an iterative AI development technique that uses a simple loop to repeatedly feed prompts to an AI agent until completion. Named after The Simpsons character, it embodies the philosophy of **persistent iteration** despite setbacks.

### Core Principles

- **Iteration > Perfection** - Don't aim for perfect on first try, let the loop refine the work
- **Failures Are Data** - Deterministically bad means failures are predictable and informative
- **Operator Skill Matters** - Success depends on writing good prompts, not just having a good model
- **Persistence Wins** - Keep trying until success, the loop handles retry logic automatically

Learn more at [awesomeclaude.ai/ralph-wiggum](https://awesomeclaude.ai/ralph-wiggum)

## What This Demo Does

This repository demonstrates the Ralph Wiggum Method for autonomous coding loops using .NET and GitHub Copilot CLI. The loop drives Copilot to create a .NET 10 Hello World console app that prints a random greeting in multiple languages, plus unit tests. Output is written to the repository root (src and tests folders).

By default this sample uses the `gpt-5-mini` model, so no premium request is needed.
If you run into `Model call failed` or any other rate limit error please use a premium model by setting the `$Model` variable in [ralph.ps1](ralph.ps1) to e.g. `gpt-5.1-codex-mini`.

## Quick Start

### Run the loop

From the repository root:

```powershell
./ralph.ps1
```

## Configuration

### Change the AI Model

You can use premium models by setting the `$Model` variable in [ralph.ps1](ralph.ps1):

```powershell
$Model = "gpt-5.1-codex-mini"
```

## Repo Structure

- **ralph/** - Prompts, PRDs, and loop state
  - **ralph/prd.toon** - Task definitions (product requirements) for the loop
  - **ralph/state/** - Loop progress
  - **ralph/AGENTS.md** - Instructions for coding agents
  - **ralph/learnings.md** - Loop learnings and observations
- **ralph.ps1** - Main script to run the loop

## Requirements

- Windows PowerShell (or PowerShell 7+)
- .NET 10 SDK
- GitHub Copilot CLI authenticated

## How It Works

1. The PowerShell script feeds PRD files to Copilot CLI in iterations
2. Copilot generates code, tests, and validates output
3. Loop continues until completion or max iterations reached
4. Progress and learnings are saved in `ralph/learnings.md`

## Sample Files Generated

```shell
│
├── src
│   └── HelloWorld
│       ├── bin
│       ├── obj
│       ├── GreetingProvider.cs
│       ├── HelloWorld.csproj
│       └── Program.cs
│
├── tests
│   └── HelloWorld.Tests
│       ├── bin
│       ├── obj
│       ├── GreetingProviderTests.cs
│       └── HelloWorld.Tests.csproj
│
└── HelloWorld.slnx
```

## Sample Console Output

```shell
╔═══════════════════════════════════════════════════════════════╗
║           Ralph Wiggum Method - Autonomous Loop               ║
╚═══════════════════════════════════════════════════════════════╝

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Starting iteration 1 of 10
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Model: gpt-5-mini
  Prompt length: 3958 characters
  Mode: --yolo (autonomous)
  Timeout: 600 seconds

  ✓ Running GitHub Copilot CLI - Complete (78,5s)

  Duration: 78,48 seconds
  Exit Code: 0

  Output:
   + ------------------------------------------------------------
  Reading project progress and PRD files to select the next user story per the iteration protocol; will open progress, prd.json, AGENTS.md, and learnings in parallel. Proceeding to read those files now.
  Creating the HelloWorld project directories so files can be added, then creating project files and updating progress, and finally building to verifyΓÇöthese steps ensure the environment is prepared before file creation and that build confirms success.
  US-001 implemented: created solution and console project, enabled nullable, implicit usings, and TreatWarningsAsErrors; build succeeded. Progress updated to mark US-001 completed. Next step: implement US-002 (greeting logic) ΓÇö proceed?
   + ------------------------------------------------------------

  Status/Info:
   + ------------------------------------------------------------
  Total usage est:       0 Premium requests
  Total duration (API):  1m 3.243s
  Total code changes:    0 lines added, 0 lines removed
  Usage by model:
      gpt-5-mini           261.7k input, 5.1k output, 239.6k cache read (Est. 0 Premium requests)
  Total duration (wall): 1m 16.932s
   + ------------------------------------------------------------

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Starting iteration 2 of 10
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Model: gpt-5-mini
  Prompt length: 3958 characters
  Mode: --yolo (autonomous)
  Timeout: 600 seconds

  ✓ Running GitHub Copilot CLI - Complete (87,8s)

  Duration: 87,85 seconds
  Exit Code: 0

  Output:
   + ------------------------------------------------------------
  Reading progress, PRD, AGENTS, and learnings to select the next user story and implement it. Running file reads and reporting intent.
  Running a file listing to locate the HelloWorld project files before editing to implement US-002.
  Building and running the project to verify the application prints exactly one randomized greeting and the build succeeds.
  Updating Program.cs to choose and print one random greeting and updating progress.txt to mark US-002 complete; then building to verify. I'll apply edits and run dotnet restore && dotnet build.
  Built successfully and updated progress to mark US-002 as current and completed; Program now prints one randomized greeting with language.
   + ------------------------------------------------------------

  Status/Info:
   + ------------------------------------------------------------
  Total duration (API):  1m 21.65s
  Total duration (wall): 1m 26.463s
  Total code changes:    0 lines added, 0 lines removed
  Usage by model:
      gpt-5-mini           153.0k input, 7.8k output, 145.7k cache read (Est. 0 Premium requests)
  Total usage est:       0 Premium requests
   + ------------------------------------------------------------

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Starting iteration 3 of 10
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Model: gpt-5-mini
  Prompt length: 3958 characters
  Mode: --yolo (autonomous)
  Timeout: 600 seconds

  ✓ Running GitHub Copilot CLI - Complete (165,5s)

  Duration: 165,48 seconds
  Exit Code: 0

  Output:
   + ------------------------------------------------------------
  Reading progress, PRD, AGENTS, and learnings to determine the next user story to implement. Reporting intent and opening the four files now.
  Reading project files to find current projects and tests, then will implement test project for US-003.
  Running a quick read of the solution file to add the test project entry into it.
  Creating GreetingProvider, test project, updating Program, solution, and progress file in one change. Running these file edits now.
  Creating tests folder and files, then restoring and running tests to verify the GreetingProvider implementation. I'll run PowerShell to create directories/files and execute dotnet restore && dotnet test.
  Inspecting the generated test project file to diagnose the XML parse error; running report_intent and reading the file.
  Created GreetingProvider, wired Program to use it, added xUnit test project and a test that validates greeting selection, updated solution and progress.
  Next steps: run or inspect results locally; tests passed here.
   + ------------------------------------------------------------

  Status/Info:
   + ------------------------------------------------------------
  Total duration (API):  2m 30.846s
  Total duration (wall): 2m 44.037s
  Total code changes:    0 lines added, 0 lines removed
  Usage by model:
      gpt-5-mini           467.7k input, 11.6k output, 439.6k cache read (Est. 0 Premium requests)
  Total usage est:       0 Premium requests
   + ------------------------------------------------------------


╔═══════════════════════════════════════════════════════════════╗
║              All stories complete! Great success!             ║
╚═══════════════════════════════════════════════════════════════╝
```


## Credits

- Ralph Wiggum Method by [Geoffrey Huntley](https://ghuntley.com/ralph/)
- Some inspiration from [Dariusz` Mediator Challenge](https://codeberg.org/dariuszparys/mediator-challenge)
- Built by [BEN ABT](https://github.com/benjaminabt)
- Powered by GitHub Copilot CLI