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
  - **ralph/prds/** - Task definitions (product requirements) for the loop
  - **ralph/state/** - Loop progress and learnings
  - **ralph/AGENTS.md** - Instructions for coding agents
- **ralph.ps1** - Main script to run the loop

## Requirements

- Windows PowerShell (or PowerShell 7+)
- .NET 10 SDK
- GitHub Copilot CLI authenticated

## How It Works

1. The PowerShell script feeds PRD files to Copilot CLI in iterations
2. Copilot generates code, tests, and validates output
3. Loop continues until completion or max iterations reached
4. Progress and learnings are saved in `ralph/state/`

## Sample Files Generated

```shell
RALPH-LOOP
├── ralph
│   │
│   └── state
│       ├── learnings.md
│       └── progress.txt
├── src
│   └── HelloWorld
│       ├── bin
│       ├── obj
│       ├── Greeter.cs
│       ├── HelloWorld.csproj
│       └── Program.cs
│
├── tests
│   └── HelloWorld.Tests
│       ├── bin
│       ├── obj
│       ├── HelloSelectorTests.cs
│       ├── HelloWorld.Tests.csproj
│       └── UnitTest1.cs
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

Total usage est:       0 Premium requests
Total duration (API):  1m 10.308s
Total duration (wall): 1m 20.419s
Total code changes:    0 lines added, 0 lines removed
Usage by model:
    gpt-5-mini           312.9k input, 4.2k output, 298.1k cache read (Est. 0 Premium requests)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Starting iteration 2 of 10
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total usage est:       0 Premium requests
Total duration (API):  44s
Total duration (wall): 47s
Total code changes:    0 lines added, 0 lines removed
Usage by model:
    gpt-5-mini           67.2k input, 3.2k output, 51.1k cache read (Est. 0 Premium requests)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Starting iteration 3 of 10
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total usage est:       0 Premium requests
Total duration (API):  1m 41.443s
Total duration (wall): 1m 49.425s
Total code changes:    0 lines added, 0 lines removed
Usage by model:
    gpt-5-mini           564.0k input, 3.6k output, 525.4k cache read (Est. 0 Premium requests)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Starting iteration 4 of 10
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total usage est:       0 Premium requests
Total duration (API):  2m 22.341s
Total duration (wall): 2m 28.481s
Total code changes:    0 lines added, 0 lines removed
Usage by model:
    gpt-5-mini           266.5k input, 9.2k output, 259.1k cache read (Est. 0 Premium requests)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Starting iteration 5 of 10
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total usage est:       0 Premium requests
Total duration (API):  1m 51.235s
Total duration (wall): 2m 6.651s
Total code changes:    0 lines added, 0 lines removed
Usage by model:
    gpt-5-mini           578.1k input, 6.4k output, 562.4k cache read (Est. 0 Premium requests)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Starting iteration 6 of 10
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total usage est:       0 Premium requests
Total duration (API):  3m 4.248s
Total duration (wall): 3m 10.498s
Total code changes:    0 lines added, 0 lines removed
Usage by model:
    gpt-5-mini           589.7k input, 10.8k output, 566.5k cache read (Est. 0 Premium requests)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Starting iteration 7 of 10
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total usage est:       0 Premium requests
Total duration (API):  43s
Total duration (wall): 46s
Total code changes:    0 lines added, 0 lines removed
Usage by model:
    gpt-5-mini           66.6k input, 3.4k output, 62.7k cache read (Est. 0 Premium requests)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Starting iteration 8 of 10
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total usage est:       0 Premium requests
Total duration (API):  36s
Total duration (wall): 39s
Total code changes:    0 lines added, 0 lines removed
Usage by model:
    gpt-5-mini           23.8k input, 3.2k output, 22.5k cache read (Est. 0 Premium requests)

╔═══════════════════════════════════════════════════════════════╗
║              All stories complete! Great success!             ║
╚═══════════════════════════════════════════════════════════════╝
```

You can also use premium models by setting the `$Model` variable in `ralph.ps1` to e.g. `gpt-5.1-codex-mini`.

```shell

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Starting iteration 1 of 10
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total usage est:       0.33 Premium requests
Total duration (API):  2m 39.786s
Total duration (wall): 2m 49.081s
Total code changes:    0 lines added, 0 lines removed
Usage by model:
    gpt-5.1-codex-mini   460.5k input, 11.0k output, 451.8k cache read (Est. 0.33 Premium requests)
```

## Credits

- Ralph Wiggum Method by [Geoffrey Huntley](https://ghuntley.com/ralph/)
- Some inspiration from [Dariusz` Mediator Challenge](https://codeberg.org/dariuszparys/mediator-challenge)
- Built by [BEN ABT](https://github.com/benjaminabt)
- Powered by GitHub Copilot CLI