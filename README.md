# Momentum

Momentum is an Android-first personal productivity app built with Flutter. It
helps you capture what matters, decide what to work on next, and see the
progress you are making.

> **Milestone 1 — application shell.**
> This milestone delivers the foundation the rest of the product is built on:
> a feature-oriented project structure, Material 3 theming with a persisted
> user preference, declarative navigation with a tabbed shell, and an
> automated test suite that locks the theme and navigation behaviour in.
> See [Roadmap](#roadmap) for what comes next.

## Features

- **Material 3 design system** with light and dark colour schemes generated
  from a single brand seed colour.
- **Three theme modes** — system, light and dark. The selection is persisted
  on the device and restored on the next launch, before the first frame is
  drawn, so the app never flashes the wrong theme.
- **Tabbed bottom navigation** across Today, Tasks, Goals and Progress. Each
  tab keeps its own navigation stack, so switching away and back preserves
  where you were.
- **Settings** reachable from the app bar, with a full-screen theme picker.
- **Honest empty states.** Every section explains what will appear there
  instead of showing placeholder data.

## Tech stack

| Concern | Choice | Version |
| --- | --- | --- |
| State management | [Riverpod](https://riverpod.dev) (`flutter_riverpod`) | `^3.3.2` |
| Navigation | [GoRouter](https://pub.dev/packages/go_router) | `^17.2.3` |
| Local persistence | [SharedPreferences](https://pub.dev/packages/shared_preferences) | `^2.5.5` |
| Design system | Flutter Material 3 | Flutter 3.35.6 / Dart 3.9.2 |

### Why these versions are pinned

The project targets **Dart 3.9.2** (Flutter 3.35.6). The current releases of
the packages above require a newer SDK:

| Package | Latest release | Requires | Pinned to |
| --- | --- | --- | --- |
| `flutter_riverpod` | 3.4.3 | Dart 3.12 | 3.3.2 |
| `go_router` | 18.1.1 | Dart 3.12 | 17.2.3 |
| `shared_preferences` | 2.5.6 | Dart 3.11 | 2.5.5 |

Pinning keeps the project building on the toolchain that is installed. Lift
the pins once the SDK is upgraded.

### A note on code generation

Riverpod's code generator (`riverpod_generator` / `build_runner`) **cannot be
resolved on Dart 3.9.2** — every candidate version pulls in an `analyzer`
release that requires a newer `meta` than the one Flutter 3.35.6 pins. The
providers in this project are therefore written by hand. This is a toolchain
constraint, not a style choice, and it disappears when the SDK is upgraded.

## Getting started

### Prerequisites

- Flutter **3.35.6** (stable) or newer, with the Dart SDK bundled with it.
  Check with `flutter --version`.
- An Android device or emulator, and the Android toolchain configured for
  Flutter. Check with `flutter doctor`.

### Run the app

```bash
flutter pub get
flutter run
```

The app targets Android first, but it also runs on the other platforms
Flutter supports.

### Run the tests

```bash
flutter test
```

### Static analysis

```bash
flutter analyze
```

## Project structure

The code is organised by feature rather than by technical layer, so everything
that belongs to a feature lives together.

```
lib/
├── main.dart                       # Bootstraps SharedPreferences, then runs the app
├── app/                            # Application-wide wiring
│   ├── app.dart                    # MaterialApp.router: theme mode + router
│   ├── router.dart                 # GoRouter configuration and route table
│   └── routes.dart                 # Route paths and bottom navigation metadata
├── core/                           # Cross-cutting concerns
│   └── theme/
│       ├── app_theme.dart          # Material 3 light and dark themes
│       ├── theme_controller.dart   # Riverpod notifier owning the theme mode
│       └── theme_preferences.dart  # SharedPreferences read/write
├── features/                       # One directory per feature
│   ├── shell/home_shell.dart       # Scaffold, app bar and bottom navigation
│   ├── today/today_page.dart
│   ├── tasks/tasks_page.dart
│   ├── goals/goals_page.dart
│   ├── progress/progress_page.dart
│   └── settings/settings_page.dart
└── shared/widgets/empty_state.dart # Reusable empty state placeholder

test/
├── app/
│   ├── navigation_test.dart        # Bottom navigation and settings routing
│   └── theme_behavior_test.dart    # Theme selection, persistence and rendering
├── core/theme/
│   ├── app_theme_test.dart
│   ├── theme_controller_test.dart
│   └── theme_preferences_test.dart
├── helpers/test_app.dart           # Builds the app with in-memory preferences
└── widget_test.dart                # Smoke test
```

## Architecture notes

### State management

`flutter_riverpod` is used without code generation (see above). State lives in
providers declared next to the code that owns them:

- `sharedPreferencesProvider` — exposes the `SharedPreferences` instance to
  the widget tree. It is created once in `main()` and injected through
  `ProviderScope(overrides: ...)`, so the rest of the app never deals with
  asynchronous plugin initialisation.
- `themeModeProvider` — a `Notifier<ThemeMode>` that reads the persisted
  selection when it is first built and writes it back on every change.

### Navigation

`GoRouter` is configured with a `StatefulShellRoute.indexedStack`. Each of
the four tabs is a branch with its own navigator, which preserves per-tab
navigation state. The Settings screen is a root-level route outside the shell,
so it covers the bottom navigation and is dismissed with the system back
button.

### Theming and persistence

`AppTheme` builds the light and dark `ThemeData` from a single seed colour with
`ColorScheme.fromSeed`. The user's choice is stored under the `theme_mode` key
in `SharedPreferences` as the name of the `ThemeMode` enum value. Unreadable or
unknown stored values fall back to `ThemeMode.system`, so a corrupted
preference can never lock the user out of the app.

## Roadmap

| Milestone | Scope |
| --- | --- |
| **1 — Foundation** | ✅ Project structure, Material 3 theming, persisted theme selection, tabbed navigation, settings, tests |
| 2 | Task capture and CRUD, local persistence (SQLite) |
| 3 | Goals and their link to tasks, progress tracking |
| 4 | Reminders and notifications, backup and sync |
| 5 | Accounts, cross-device sync, AI-assisted planning |

## Out of scope for Milestone 1

Deliberately **not** part of this milestone: task CRUD, SQLite, notifications,
Supabase, authentication and AI features.
