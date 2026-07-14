# Client Project Tracker

A flutter app for managing client projects — built for a take-home assessment,
so the focus here is on structure and code quality rather than piling on features.

You can create, view, edit, and delete projects, plus search and filter the list. It
works fully offline since everything is stored locally in SQLite.

## Tech choices, and why

- **Flutter** — I opted to use cross platform development instead of Native since I'm upskilling my tech stack
- **Riverpod** for state management.
- **Drift** (SQLite) for local storage instead of something like Hive or plain
  shared_preferences.
- **fpdart** (`Either<Failure, T>`) for error handling in the domain layer, so
  failures are a return value instead of something you have to remember to catch five
  layers up.
- Architecture is **Clean Architecture** — data / domain / presentation, one direction
  of dependency. 

## Features Implemented

**Core requirements**
- Project List screen — client name, project name, status, priority, due date
- Create Project screen with full validation
- Edit Project screen
- Project Details screen — full record, plus Edit and Delete
- Full CRUD, backed by local SQLite (Drift) — no mock data, no backend dependency
- Form validation — required fields, due date can't be before start date, description length capped, with inline per-field errors
- Loading states on every async boundary (list fetch, single fetch, create, update, delete)
- Error handling — every failure path shows a readable message and, where it makes sense, a retry action. No raw exceptions ever reach the screen.

**Bonus features (all implemented)**
- Offline support — SQLite is the primary store
- Search — debounced, filters by client or project name
- Filtering — by status and priority, combinable with search
- State persistence — last-used search/filter and theme choice are remembered between sessions
- Dark mode — full light/dark theme, follows system by default with a manual override, badge colors checked against WCAG AA contrast in both modes
- Clean navigation — declarative routing (go_router), typed path params, no raw string-based navigation


## Setup

You'll need:
- Flutter SDK (stable channel) — I built this against 3.24+
- An iOS simulator or Android emulator (or a physical device)
- Dart's usual tooling comes bundled with Flutter, nothing extra to install there

Steps:

```bash
git clone <repo-url>
cd client_project_tracker
flutter pub get
```

This project uses code generation (Riverpod + Drift both generate code), so after
`pub get` you'll need to run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

If you're actively changing entities, providers, or the Drift schema while developing,
run the watcher instead so you don't have to keep re-running it manually:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Running the app

```bash
flutter run
```

Pick your target device/simulator when prompted, or pass `-d <device_id>` if you
already know which one you want. Tested on an Android emulator (Pixel 10 Pro, API 34). No iOS-specific code was
written, but I haven't been able to verify on an iOS simulator/device — that would
need a Mac, which I didn't have available for this build.

To run the test suite:

```bash
flutter test
```

## Assumptions I made

A few things weren't fully spelled out in the brief, so here's what I decided and why:

- **No backend.** I went local (SQLite via Drift) so the app is genuinely offline-first rather than "mock data.
- **After creating a project, the user lands back on the project list screen, where the new entry
  is immediately visible (the list refreshes automatically, no manual pull-to-refresh
  needed). Editing an existing project returns to the project's Details screen
  instead, since that's the more natural "you were just looking at this, here it is
  again" flow.
- **Delete requires a confirmation dialog.** Not required, but deleting a
  client's project record without confirmation felt like an easy way to lose real data
  by accident, so I added the guard rail.
- **Search and filtering, dark mode, and state persistence** (last search/filter and
  theme choice remembered between sessions) were listed as bonus features — I built
  all three in, since they didn't add much complexity given the architecture was
  already set up to support them cleanly.
- **Seed data.** The app seeds itself with the 12 sample projects provided for this
  assessment on first launch

