# SpydrNotes

An offline-first Flutter app for iOS and Android. The product plan is in [extra/PLAN.md](extra/PLAN.md).

This is the new app on `main`. The previous React/MongoDB app remains on the `legacy` branch. The app currently supports local quick capture, a notes list, and basic full-text search. Phase 1 also includes repository foundations for folders, tags, and links, plus isolated graph and archive prototypes. The graph tab remains a placeholder for real note data; editing, linking, organization UI, and full backup/restore are planned for later phases.

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
flutter test test
flutter build apk --debug
```

The [Phase 1 platform workflow](.github/workflows/phase1.yml) builds the iOS simulator app and runs a quick capture and 100-node graph smoke test on an Android emulator. These checks run on pushes to `main` and can also be started manually in GitHub Actions.

## Database changes

Schema version 1 is saved in `drift_schemas/`. When changing tables, increase `schemaVersion`, generate migration steps with `dart run drift_dev make-migrations`, implement any extra SQL migration needed for the FTS5 table and triggers, and test upgrading an existing database. The FTS5 objects are created outside Drift's generated table schema and need explicit handling in future migrations.

## Project layout

- `lib/app/`: app shell, navigation, and themes.
- `lib/domain/`: app models and repository contracts.
- `lib/data/database/`: local SQLite schema and FTS5 index.
- `lib/data/repositories/`: Drift-backed repository implementations.
- `lib/presentation/`: screens, widgets, and Riverpod providers.

Database schema version 1 creates the core note, folder, tag, link-index, history, and preference tables. The FTS5 table is a derived index of note title and content. All data stays on the device.

`VaultArchivePrototype` demonstrates a zip backup/restore round trip into an empty vault. It preserves note content, IDs, folders, tags, and note-tag membership. It is not exposed as a user backup feature; full validation, settings/history, link-index rebuilding, safety copies, and merge/replace handling are Phase 5 work.
