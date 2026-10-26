# SpydrNotes

An offline-first Flutter app for iOS and Android. The product plan is in [extra/PLAN.md](extra/PLAN.md).

This is the new app scaffold on `main`. The previous React/MongoDB app remains on the `legacy` branch. The scaffold currently supports local quick capture, a notes list, and basic full-text search. The graph tab is a placeholder; editing, linking, folders, backup/restore, and release polish are still planned work.

## Get started

Use Flutter 3.47 or newer. Android builds need the Android SDK. Building or running the iOS app needs macOS with Xcode.

```sh
flutter pub get
dart run build_runner build
flutter run
```

The generated Drift code is checked in, so regeneration is only needed after changing the database tables.

## Checks

```sh
flutter analyze
flutter test
```

## Project layout

- `lib/app/`: app shell, navigation, and themes.
- `lib/domain/`: app models and repository contracts.
- `lib/data/database/`: local SQLite schema and FTS5 index.
- `lib/data/repositories/`: Drift-backed repository implementations.
- `lib/presentation/`: screens, widgets, and Riverpod providers.

Database schema version 1 creates the core note, folder, tag, link-index, history, and preference tables. The FTS5 table is a derived index of note title and content. All data stays on the device.
