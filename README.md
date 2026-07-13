# Client Project Tracker

A small Flutter app for managing client projects — built for a take-home assessment,
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

Full breakdown of the architecture decisions and folder structure is documented
separately (kept out of this repo on purpose — see the note at the bottom).

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
already know which one you want. Tested on an iOS simulator and an Android emulator —
no platform-specific code beyond what Flutter handles for you.

To run the test suite:

```bash
flutter test
```

## Assumptions I made

A few things weren't fully spelled out in the brief, so here's what I decided and why:

- **No backend.** I went local (SQLite via Drift) so the app is genuinely offline-first rather than "mock data.
- **After creating a project, I decided to send the user to that project's Details
  screen** rather than just back to the list — felt like a better confirmation that the
  save actually worked, versus dropping them back into a list they now have to scan.
- **Delete requires a confirmation dialog.** Not required, but deleting a
  client's project record without confirmation felt like an easy way to lose real data
  by accident, so I added the guard rail.
- **Search and filtering, dark mode, and state persistence** (last search/filter and
  theme choice remembered between sessions) were listed as bonus features — I built
  all three in, since they didn't add much complexity given the architecture was
  already set up to support them cleanly.

