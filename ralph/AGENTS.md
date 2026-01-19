# AGENTS.md for .NET HelloWorld Project

## Project Overview
This is a simple .NET 10 console application that prints exactly one random greeting in different languages on each run.  
The project follows a standard repository structure with application code under `src/HelloWorld` and unit tests under `tests/HelloWorld.Tests`.  
The purpose of this file is to guide coding agents to understand project structure, build steps, testing commands, and conventions.

## Tech Stack
- .NET 10 (net10.0)
- C# console application
- xUnit (or another .NET test framework) for unit testing

## Setup Instructions
- Ensure .NET 10 SDK is installed
- No additional dependencies or package managers required
- All source code is in `src/HelloWorld` and all tests are in `tests/HelloWorld.Tests`

## Key Commands

### Build & Run

- Restore packages and build:  
  ```bash
  dotnet restore
  dotnet build
  ```

- Run the application:  
  ```bash
   dotnet run --project src/HelloWorld
  ```

- Run tests and see results:
    ```bash
    dotnet test tests/HelloWorld.Tests
    ```

## Project Structure

- src/HelloWorld/ — main console application code
- tests/HelloWorld.Tests/ — unit tests for greeting selection

## Coding Conventions

- Use nullable reference types
- Use implicit usings
- Warnings as errors enabled
- Follow idiomatic C# and .NET best practices

## Behavior Requirements

- Print one greeting per run
- Choose greeting randomly from predefined list
- Output format should include both the greeting text and its language

##Testing Expectations

- Tests must validate that greeting logic:
- Only returns greetings from the fixed list
- Can be reliably tested with predictable randomness (use DI/injection or seeded RNG in tests)

## PR and Commit Rules

- Include updates to AGENTS.md when adding workflows or conventions
- Ensure all tests pass before merge

## Boundaries

- Do not modify unrelated components or directories
- Do not add additional executables or services