# Client Project Tracker — Project Instructions

Read and follow this file for every task in this repository. If a request conflicts
with something below, point out the conflict instead of silently picking one side.

This repository is self-contained. Do not draw on patterns, naming, or conventions from
any other project — only from these rules, the docs below, and the code already present
in `lib/` and `test/`.

## Core context — read first

Before writing or modifying any code, read:
- `docs/constitution.md` — binding rules: tech stack, architecture mandate, DTO/Entity/
  Model contract, DI rules, memory management, testing mandate, naming conventions.
- `docs/system_requirements.md` — functional/non-functional requirements, the exact
  Project data model, and per-screen behavior.
- `docs/architecture.md` — the Clean Architecture layering, folder structure, data flow,
  and testing strategy.

## Architecture rules (applies to everything under lib/)

- `lib/features/*/domain/**` must contain zero `package:flutter/...` imports. Plain
  Dart only.
- `lib/features/*/presentation/**` may import `domain/` but never `data/` directly.
- `lib/features/*/data/**` implements interfaces defined in `domain/repositories/`.
  `domain/` never imports from `data/`.
- No business logic (validation, data transformation, calculations) inside a widget's
  `build()` method. Business logic lives in `domain/usecases` or `domain/validators`.
- Every repository method that can fail returns `Either<Failure, T>` (fpdart) — never
  throws across the domain/presentation boundary. See `core/errors/failures.dart`.
- New dependencies are provided via Riverpod providers using constructor injection.
  No service locator, no static singleton reached into directly from a widget/notifier.
- Follow the exact folder structure in `docs/architecture.md` Section 3 for any new
  feature or file. If a new file doesn't obviously fit, ask rather than inventing a new
  top-level folder.

## TDD rules (applies to lib/ and test/)

- When implementing a new use case, repository method, validator, or notifier: generate
  the test file first (or alongside), not after. The test should fail against a
  not-yet-implemented class before the implementation is written.
- Never generate a `data/`, `domain/`, or `presentation/` class without also generating
  or updating its corresponding test in `test/features/projects/...` mirroring the
  `lib/` path.
- Domain layer (use cases, validators, entities) tests use plain `flutter_test` with no
  Flutter widget dependencies.
- Repository implementation tests use an in-memory Drift database
  (`NativeDatabase.memory()`), not mocks, so real SQL behavior is exercised.
- Use case tests use `mocktail` to fake the repository interface.
- Notifier/provider tests use `ProviderContainer(overrides: [...])` to inject fakes and
  assert on `AsyncValue` state transitions (loading -> data / loading -> error).
- Widget tests must cover: loading state, empty state, error + retry, and (for the
  form) at least one validation failure path.
- Do not mark a feature complete or move to the next screen if any of the above test
  types are missing for the code just written.

## DTO / Entity / Model rules (applies to data/ and domain/entities/)

- **Entity** (`domain/entities/`): pure business object, no serialization code, no
  persistence annotations, no Flutter imports. This is what use cases and UI consume.
- **Model** (`data/models/`, e.g. Drift table definitions): the persistence-layer shape.
  Owns schema concerns only.
- **DTO** (`data/models/`, suffix `Dto`): wire format for a remote API, with
  `fromJson`/`toJson`. Only add these when a remote data source is actually introduced —
  don't pre-build DTOs for an API that doesn't exist yet.
- Conversions between these three are explicit named mapper functions/extensions (e.g.
  `ProjectRow.toEntity()`, `Project.toCompanion()`), each unit tested on its own, never
  inline conversion logic scattered across repositories.
- Never let a widget or notifier construct or consume a DTO/Model directly — only
  `Entity` crosses into `presentation/`.
