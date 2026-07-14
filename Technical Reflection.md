# Technical Reflection

## Why did you choose this implementation approach?

Clean Architecture because given the requirements a DTO/Entity/Model split would be the best approach
since this would be judged on architecture. Also, it keeps business logic separate from the UI, which
matters for TDD.

I chose Riverpod to handle both state management and dependency injection, so I'm not running
two separate systems for "how does a widget get its data" and "how do classes get
their dependencies."

## What tradeoffs did you make?

Considered more structure than a 4-screen app with a beautiful UI.

No backend. This is fully local with SQLite instead of "mock data." 

I used Cursor and then Claude during implementation, with a test-first approach instead
of doing solo coding for the development process. But a thorough reading and reviewing 
of the diffs were done strictly.

## What would you improve if given additional time?

- Wire up a real API behind the existing repository interface, to actually prove out
  the swap-ability the architecture is supposed to give for free
- A more polished UI/UX implementation

## What was the most challenging part of this assessment?

Honestly, environment issues more than the code itself. I hit a black screen in
release mode on the Android emulator with zero error output — no crash, no stack
trace, nothing in the terminal. Did took a real debugging pass.

## Did you use AI tools during development?

Yes. I used Claude, Copilot and Cursor throughout.

Implementation went layer by layer, test-first: for each use case, repository,
notifier, and screen, Copilot wrote the failing test, then the implementation, then I
reviewed the diff before moving to the next piece.