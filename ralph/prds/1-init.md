# User Story 1 - .NET Initialization

Story: 001

## Description
As a developer, I want a new .NET 10 solution with a console application scaffolded in a standard repository layout so that I have a clean foundation for further development.

## Scope
- Create a .NET 10 solution
- Console application located at `src/HelloWorld`
- Use modern .NET defaults

## Acceptance Criteria
- A `.slnx` file exists at the repository root
- The console project is located at `src/HelloWorld`
- Target framework is `net10.0`
- Nullable reference types are enabled
- Implicit usings are enabled
- Warnings are treated as errors