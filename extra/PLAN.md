# SpydrNotes — Master Plan

## 1. Product Overview

**SpydrNotes** is a free, offline-first note-taking and planning app for students and general users, targeting iOS and Android. It helps people capture ideas, organize notes, and connect related concepts through an interactive spider-web graph.

Built with Flutter. Notes are stored locally on the device. There is no account system, cloud sync, or collaboration in the first release.

## 2. Product Goals & Principles

### Goals

- Make capturing and finding notes quick on a phone.
- Let users connect related notes and explore those connections visually.
- Support studying, planning, and general note-taking without an internet connection.
- Keep users' notes portable through import, export, and backup.
- Keep the initial implementation manageable for a solo developer while leaving room for future growth.

### Principles

1. **Offline-first:** Core features work without a network connection.
2. **User-owned data:** Notes can be exported in accessible, portable formats.
3. **Connections matter:** Linking and graph exploration are central, not decorative.
4. **Mobile-first:** Common actions work comfortably with one hand; no reliance on hover.
5. **Simple to start:** Users can write notes immediately, with no required setup.
6. **Data safety:** Deleted notes are recoverable until explicitly purged; backups and restores never silently destroy data.

## 3. Target Users & Use Cases

- **Students:** class notes, study topics, revision links, project planning.
- **General users:** personal notes, idea capture, lists, planning.
- **Learning and research:** connect related concepts, follow backlinks, explore a topic's surrounding notes.

## 4. Scope

### In scope for the first release

- iOS and Android apps built with Flutter.
- Local-only note storage (SQLite).
- Notes with Markdown support (edit + rendered reading mode).
- Folders and tags for organization.
- Search, backlinks, and `[[wiki-style]]` note linking.
- An interactive spider-web graph (neighborhood-focused).
- Quick capture, pinned notes, recent notes.
- Breadcrumb navigation.
- Trash (recoverable deletion) and archive.
- Markdown import/export and a complete backup/restore flow.
- Light/dark/system themes and basic appearance and graph customization.

### Not in the first release

- Cloud sync or accounts.
- Collaboration or shared notes.
- Web or desktop applications.
- AI-generated summaries or other AI features.
- Attachments and images (data model leaves room for them).
- PDF export.
- Complex project management features.
- Link types ("references", "relates-to", etc.) — single link type for v1.

## 5. Core Features

### 5.1 Notes & Editor

- Markdown-capable editor with a readable preview / rendered reading mode (toggle or split where the screen allows).
- Support note titles, headings, paragraphs, lists, checklists (`- [ ]`), inline code, code blocks, quotes, links, and tables.
- Autosave locally after ≤2 s of inactivity and at least every 2 s during continuous typing; attempt an immediate flush on focus loss or app backgrounding. Show "saved" only after a successful database commit. An abrupt process kill may bypass lifecycle callbacks, so the last uncommitted edits can be lost.
- Handle empty notes gracefully; allow deleting, archiving, and moving notes.
- Basic templates: blank note, class notes, planning note (expand later).
- Word count in the editor (low-cost, useful for students).

### 5.2 Organization

- **Folders:** simple hierarchy (2–3 levels typical). Prevent parent cycles. Deleting a nonempty folder requires choosing where its notes and child folders move; deleting an empty folder requires confirmation.
- **Tags:** multiple tags per note, independent of folder location.
- **Pinned notes:** frequently used notes easy to reach.
- **Recent notes:** recently opened or edited notes (default: last 10), ordered by the later of `lastOpenedAt` and `updatedAt`.
- **Trash:** deleted notes remain recoverable indefinitely in v1; permanent purge requires a second confirmation. Trashed notes are excluded from normal lists, search, and graph results.
- **Archive:** remove clutter without deleting. Archived notes are excluded from the home list but remain searchable and linkable, with an archive filter.
- **Breadcrumbs:** current folder path and graph-exploration trail; tapping a crumb returns to that location.

### 5.3 Search & Discovery

- Full-text search over note titles and content (SQLite FTS5-backed).
- Filter results by folder, tag, and date range; pinned and archived filters.
- Results show a matching-text excerpt with the match highlighted, and a result count.
- Local search history (recent queries), with a clear-history action.
- A way to find unlinked ("orphan") notes.
- Search reachable from main navigation and openable from anywhere.

### 5.4 Linking & Backlinks

- The link picker presents note titles, and reading mode renders them as tappable links. Stored Markdown uses `[[Note title|note-uuid]]`, preserving a readable label and a stable target ID; users may type `[[Note title]]` as shorthand.
- Create a link by picking an existing note or creating a new linked note.
- Manually typed `[[Note title]]` resolves only when exactly one active note has that normalized title; on save it becomes the ID-bearing form. Duplicate titles are allowed, so ambiguous matches require the user to pick a target.
- Show distinct outgoing links on the source note and backlinks on the target note.
- **Stable IDs:** the ID in stored Markdown is authoritative. Renaming a note updates display titles in incoming links in the same database transaction; the ID continues to work even if a label is stale.
- **Broken links:** unresolved title-only links and links to missing or trashed targets have a clear state with repair/remove actions. Restoring a trashed target restores its ID-based links.
- **Circular links:** detected and allowed (harmless for rendering); surface a notice if a cycle would cause confusion, but never infinite loops in traversal.
- Single link type for v1; the data model permits a `linkType` later.

### 5.5 Spider-Web Graph View

- Notes as nodes, links as edges; pan, zoom, and node selection.
- Tapping a node opens the note, with a clear way back to the graph.
- Selecting a note shows its direct connections, with an option to expand one more ring (neighborhood exploration) — **not** the whole vault by default.
- Filters: folder, tag, and connection depth.
- Nodes distinguishable by selection state and, where helpful, folder or tag (with a legend).
- **List-based alternative view** for users who prefer not to navigate visually.
- Performance targets: smooth at ≥100 visible nodes; MVP render cap 500 nodes with a clear "narrow the filter" state beyond.
- Identify orphan notes (no incoming or outgoing links) in a dedicated list; they cannot appear in another note's linked neighborhood.

### 5.6 Capture & Quick Entry

- Prominent "New note" action (tab-bar FAB / home action).
- Create a note from search, a folder, or the graph.
- New notes save immediately with a default title; renameable later.
- Short capture flow: folder and tag assignment optional, never required.
- Quick-capture dialog for title + short content without entering the full editor.

### 5.7 Customization

- Light, dark, and system themes.
- Small range of text-size choices.
- Basic graph preferences: node label size, label visibility per zoom level.
- Keep customization optional; core features never depend on settings.

### 5.8 Import, Export & Backup

- **Import:** Markdown files, preserving titles and formatting. A standalone file without vault metadata creates a new note ID, even when a title matches; offer an explicit choice to update an existing note instead. Preserve ID-bearing links to known notes and show unknown IDs or ambiguous title-only links for repair.
- **Export single note:** as Markdown.
- **Export all / full backup:** one portable zip with Markdown files and a human-readable manifest preserving every note ID and state, folder hierarchy, tags, settings, search history, and timestamps. Link IDs remain in Markdown; the link index is rebuilt on restore.
- **Restore:** validate the full archive before changing data, make a safety copy of the current vault, then offer replace or merge. A differing record with the same ID is a conflict regardless of timestamp; the user chooses keep current or use backup. Never silently overwrite.
- **Round-trip guarantee (tested):** backup → fresh restore → content, folder hierarchy, tags, link targets, archive/trash/pin state, settings, and history intact. Standalone Markdown import has narrower guarantees.

### 5.9 Mobile UX & Accessibility

- Touch-friendly controls; no hover-dependent behavior.
- Bottom sheets for secondary actions; large touch targets (≥44 pt).
- Consistent system back navigation.
- Keyboard-aware layout: the active editor area is never hidden.
- Empty states that explain how to create the first note or connection.
- Confirmation for destructive actions (delete, purge, restore), but not for routine editing.
- Screen-reader support: labeled graph nodes, accessible fallback to the list view.

## 6. Navigation Structure

Bottom navigation bar with three tabs:

1. **Notes** — recent notes, pinned notes, folders; prominent "New note" action.
2. **Graph** — the interactive spider-web view.
3. **Search** — full-text search and filters.

Note-specific actions remain available from the editor.

## 7. Data Model

Notes, folders, and tags use stable UUIDs so renaming or moving never breaks references. Join/index rows may use composite keys. No device-path or filename is an entity identifier.

### Note

| Field | Type | Notes |
|---|---|---|
| `id` | uuid | |
| `title` | string | |
| `content` | string | Markdown |
| `folderId` | uuid? | null = unfiled |
| `createdAt` | datetime | |
| `updatedAt` | datetime | |
| `lastOpenedAt` | datetime? | recent-notes ordering |
| `isPinned` | bool | |
| `isArchived` | bool | |
| `deletedAt` | datetime? | set when moved to trash |

### Folder

`id`, `name`, `parentFolderId?`, `createdAt`, `updatedAt`

### Tag

`id`, `name` (unique)

### NoteTag

`noteId`, `tagId`

### Local preferences and history

Persist theme, text size, and graph preferences locally. Store recent search queries with timestamps; users can clear them. These are included in a full backup.

### NoteLink

| Field | Type | Notes |
|---|---|---|
| `sourceNoteId` | uuid | |
| `targetNoteId` | uuid? | null if the target cannot be resolved or was purged |
| `targetIdText` | string? | ID from Markdown, retained if the target is missing |
| `rawTitle` | string | label/title as written in Markdown |
| `occurrenceIndex` | int | distinguishes repeated links in one note |
| `linkType` | string? | reserved; always null in v1 |

**Source of truth for links:** ID-bearing Markdown in `Note.content` is authoritative. `NoteLink` is a derived occurrence index, rebuilt when content changes; it includes unresolved links for the broken-link UI. Backlinks and graph edges use distinct resolved source/target pairs. Soft-deleted targets remain addressable by ID but appear unavailable; permanent purge leaves their Markdown references unresolved until repaired. All content, link-index, and rename updates run in one database transaction.

## 8. Technical Architecture

### 8.1 Tech Stack

| Concern | Choice | Rationale |
|---|---|---|
| Framework | Flutter (Dart) | Cross-platform iOS/Android from one codebase |
| Local storage | SQLite via **Drift** (typed data-access layer) | Migrations, real FTS5 full-text search, solid under 5,000+ notes |
| Search | SQLite **FTS5** virtual table, kept in sync by database triggers | Fast, offline, indexed |
| State management | **Riverpod** | Testable, dependency-injected, works well with repositories |
| Markdown (authoring) | `markdown` package + `flutter_markdown` | Preview/rendering and parsing/link extraction |
| Graph rendering | **Custom `CustomPainter`/Canvas** with a simple force-directed layout | No viable pure-Dart node-graph package of adequate quality; full control of pan/zoom/tap for a modest graph size |
| Files & sharing | `path_provider`, `file_picker`, `share_plus`, `archive` (zip) | Import/export/backup flows |
| UI | Material 3 | Platform-appropriate on both targets |

> Note: avoid `graphql_flutter` (a GraphQL client library, not a graph renderer), `fl_chart` (charting, not node graphs), and `dagre` (JS-only) — all plausible-sounding but wrong for this.

### 8.2 Architecture

- Clean separation: **presentation → application services → repositories → data sources**.
- Repositories isolate widgets from Drift/database details; the database is behind interfaces so it can be swapped or extended (future sync).
- Services (markdown parsing, link resolution, graph building, search, export) are pure, unit-testable Dart.
- Schema versioning with Drift migrations from day one.

### 8.3 Project Structure

```
spydrnotes/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart
│   │   ├── theme/          # light, dark, system themes
│   │   └── router/         # app routes / navigation
│   ├── data/
│   │   ├── models/         # notes, folders, tags, link index, preferences/history
│   │   ├── database.dart   # Drift database, migrations, FTS table
│   │   └── repositories/   # note, folder, tag, link repositories
│   ├── domain/
│   │   ├── models/         # pure-Dart entities (if kept separate from tables)
│   │   └── services/       # markdown, link resolution, graph builder, search, backup
│   ├── presentation/
│   │   ├── screens/        # home, editor, graph, search, settings
│   │   ├── widgets/        # note tile, graph canvas, editor, backlinks, quick capture
│   │   └── providers/      # Riverpod providers
│   └── utils/
├── pubspec.yaml
├── test/                   # unit tests
├── integration_test/       # e2e flows
├── android/
└── ios/
```

### 8.4 Key Dependencies (reference)

```yaml
dependencies:
  flutter:
    sdk: flutter
  drift: ^2.0.0
  sqlite3_flutter_libs: ^0.5.0
  drift_flutter: ^0.2.0        # or drift + path_provider
  flutter_riverpod: ^2.0.0
  flutter_markdown: ^0.7.0
  markdown: ^7.0.0
  path_provider: ^2.0.0
  file_picker: ^8.0.0
  share_plus: ^9.0.0
  archive: ^3.0.0
  uuid: ^4.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  drift_dev: ^2.0.0
  build_runner: ^2.0.0
  integration_test:
    sdk: flutter
```

(Use current stable versions at implementation time.)

## 9. Key Implementation Details

### 9.1 Link Parsing & Resolution

- Parse wiki links as a Markdown inline extension, outside fenced/indented code, inline code spans, and escaped text. A global regex is insufficient for these contexts.
- Accept `[[Title]]` as title-only input and `[[Title|uuid]]` as the canonical saved form. Normalize title-only input by trimming and case folding; resolve it only when exactly one active note matches. Prompt for ambiguous matches and keep missing matches unresolved.
- On save, rewrite uniquely resolved title-only links to ID-bearing Markdown and rebuild that note's `NoteLink` occurrence rows in the same transaction. The editor may expose the ID in raw Markdown; picker and preview show the readable title.
- On a target rename, rewrite the title portion of incoming ID-bearing links and update the target title in one transaction. Check source-note revisions when later saving an open editor draft so a stale draft cannot undo the rewrite. Link behavior continues to depend on the UUID, including if a label is stale in an imported file.
- Query distinct resolved pairs for backlinks and graph edges. Keep unresolved occurrences for repair; never infer a replacement target from a duplicate title or a reused title after deletion.
- Test duplicates, Unicode/case normalization, repeated links, malformed/nested brackets, escaped brackets, code spans/fences, rename, trash/restore, purge, and import of an unknown ID.

### 9.2 Graph Rendering

- Custom `CustomPainter` on a `GestureDetector`/`InteractiveViewer`-style transform layer for pan + zoom.
- **Force-directed layout**: simple spring-embedder (edge springs + node repulsion + mild centering gravity), iterated to convergence in a bounded number of steps; results cached and only recomputed when the visible subgraph changes.
- **Neighborhood loading:** by default render the selected note's direct neighbors (depth 1); "expand" adds one more ring. Never load the entire vault unfiltered.
- Render cap: 500 nodes — beyond that, show a "narrow your filters" state.
- Node styling: folder/tag color (with legend) and selection highlight. Orphans are reached through their dedicated list, then can be selected as a one-node neighborhood.
- Hit-testing for tap-to-open; node label rendering scaled with zoom (labels hidden below a zoom threshold per user preference).

### 9.3 Markdown

- Render preview with `flutter_markdown`; support: headings, lists, checklists, bold/italic, inline code, fenced code blocks, quotes, tables, links, `[[wiki-links]]` (custom inline widget rendering).
- Warn (non-blocking) on malformed syntax rather than failing.
- Code blocks get basic syntax coloring only if low-cost; otherwise monospace blocks.

### 9.4 Search

- FTS5 index over `title` + `content`; database triggers keep it synchronized on create/edit/import/restore/purge. Default queries exclude trash; archive is included only when the archive filter is enabled.
- Treat the search box as literal terms by default: escape FTS5 operators and quotes when building a parameterized `MATCH` query. Empty or punctuation-only input shows no results without an error. Reserve advanced query syntax for a later feature.
- Debounce input ≥300 ms; target <500 ms to first results on a personal vault.
- Snippet extraction with match highlighting; folder/tag/date/pin/archive filters applied in SQL. Define an orphan as a note with no active incoming or outgoing resolved links; expose this as a list filter.

### 9.5 Autosave

- Commit within 2 s after the last edit and at least every 2 s while editing continues; serialize writes so an older save cannot overwrite a newer one.
- Attempt to flush on focus loss, navigation, and lifecycle `inactive`/`hidden`. Do not rely on a terminate callback: an OS kill can skip it. Test a forced kill immediately after typing and document the possible loss of the last uncommitted edits.
- Show subtle saving/saved/error states; "saved" means the latest revision is committed. A failed write keeps the draft in the editor and offers retry rather than discarding it.

### 9.6 Backup & Restore

- Backup = zip of `notes/<note-uuid>.md` plus `vault.json`. The manifest contains a format version, note IDs and file hashes, titles and timestamps, folder IDs and parent IDs, each note's `folderId`, tag IDs and note-tag membership, pin/archive/trash state, `lastOpenedAt`, app preferences, and search history. Paths are archive details, never identity. Links live in Markdown and the derived index is rebuilt after restore.
- Validate archive version, entry paths and sizes, hashes, unique IDs, folder references, and link-ID syntax before mutation. Missing link targets remain repairable broken links. Reject unsupported versions, path traversal, corrupt files, and folder cycles with an actionable error.
- **Replace:** after validation and a successful safety copy of the current vault, replace the database contents in one transaction. Keep the safety copy until the new vault opens and its indexes pass an integrity check.
- **Merge:** match notes, folders, and tags by UUID. Identical records are skipped; differing records with the same UUID are shown as conflicts, with keep-current or use-backup choices. Show timestamps as context, not as automatic overwrite rules. New IDs import with their relationships; validate the resulting folder tree and rebuild links/search before committing. Preserve current preferences/history unless the user explicitly chooses backup values.
- Round-trip tests: backup → fresh restore and merge → assert content, IDs, hierarchy, tags, link targets, note states, settings, and history. Test invalid archives, same-ID divergence, same-title/different-ID notes, missing targets, and interrupted restores.

## 10. Development Phases

### Phase 1 — Foundation and feasibility

- Flutter project, Material 3 theme support (light/dark/system), bottom navigation scaffold.
- Drift database, tables (§7), FTS5 setup, migration framework.
- Repository interfaces for notes/folders/tags/links.
- Prove an iOS and Android device build, 100-node graph interaction, and minimal backup/restore round-trip before committing to the custom graph and archive approach.
- **Done when:** data-layer unit tests pass, a note can be written/read through a repository, and the cross-platform/graph/backup feasibility checks work.

### Phase 2 — Notes & Organization

- Note CRUD, Markdown editor with preview, autosave.
- Folders, tags, pinned and recent notes, trash + archive, breadcrumbs.
- Empty states, quick-capture flow, templates (basic).
- **Done when:** create → edit → organize → trash → restore works offline and survives app restart; forced-kill autosave behavior is measured.

### Phase 3 — Search & Linking

- FTS search with filters, snippets, history, orphan search.
- `[[wiki-link]]` authoring, ID-bearing storage, outgoing/backlinks panels, broken-link handling, circular-link safety.
- **Done when:** a link appears as outgoing from its source and as a backlink on its target; duplicate titles, renames, and trash/restore keep the intended target ID (tested).

### Phase 4 — Graph

- Canvas renderer, pan/zoom/tap, force-directed layout, neighborhood expansion.
- Filters (folder/tag/depth), node styling + legend, list-based alternative view, breadcrumbs in graph context.
- Performance pass against the 100/500-node targets.
- **Done when:** graph is usable on a mid-range Android device at 100+ nodes with smooth pan/zoom.

### Phase 5 — Portability & Release Readiness

- Markdown import/export, zip backup/restore with conflict handling.
- Round-trip and upgrade-migration tests.
- Accessibility pass, crash/error handling, low-end device testing, release builds.
- **Done when:** all §14 acceptance criteria pass on real iOS and Android devices, including failed restore and forced-kill cases.

> These are dependency-ordered gates, not an eight-week commitment. After Phase 1, estimate the remaining work from measured device builds, graph interaction, and a backup prototype. If that estimate exceeds available time, revise v1 scope explicitly; templates, word count, search history, and appearance/graph preferences are candidates to move to a later release. Do not ship without a tested full restore.

## 11. Testing Strategy

### Unit tests (Dart)

- Markdown-aware link parsing: title-only/canonical forms, duplicates, malformed/nested/escaped brackets, inline/fenced code, unknown IDs.
- Title normalization, ID resolution, rename rewrites, trash/restore, and repeated-link deduplication for graph/backlinks.
- Search query escaping, filtering logic, and snippet extraction.
- Force-directed layout convergence and determinism (seeded).
- Backup manifest serialization/deserialization, validation, ID conflicts, and folder-cycle detection.

### Widget tests

- Note editor interactions (typing, autosave state, checklist toggling).
- Search screen: query, filters, results.
- Graph widget: node tap → opens note; back-navigation.
- Theme switching preserves state; trash/restore flows with confirmations.
- Saving/saved/error states reflect actual database commits.

### Integration tests (device/emulator)

- Full flow: create → link → backlinks → graph → open from node.
- Backup/restore round-trip on a fresh install and merge into a populated vault, including folders, tags, links, note states, settings, and history.
- Reject corrupt/path-traversal archives without changing the vault; simulate a failed restore and recover from the safety copy.
- Kill the process while typing and after backgrounding; verify committed edits survive and the UI never reports uncommitted data as saved.
- Database upgrade path: old schema → migrate → data intact.
- Keyboard open/close and rotation on the editor screen.

## 12. Performance Targets

| Metric | Target |
|---|---|
| App cold start to usable | <3 s on a mid-range Android |
| Note open to editable | <500 ms |
| Search → first results (personal vault) | <500 ms |
| Graph: visible at | ≥100 nodes, smooth pan/zoom |
| Graph: render cap | 500 nodes (then prompt to narrow filters) |
| Autosave commit | ≤2 s after last keystroke and at least every 2 s during continuous typing in normal operation; background flush is best effort |
| Editor scrolling | no jank at 10k-character notes |

## 13. Risks & Mitigations

| Risk | Mitigation |
|---|---|
| **Graph performance** (dense graphs, low-end phones) | Neighborhood-only default view, filters, render cap, layout caching, list-based fallback |
| **Data loss** (edits, import/restore) | Bounded autosave commits, save-error state, soft delete, archive validation, pre-restore safety copy, atomic restore, round-trip tests |
| **Broken links after renames/edits** | ID-bearing Markdown, transactional label rewrites, derived link index, broken-link UI, dedicated tests |
| **Markdown edge cases** breaking links or preview | Markdown-aware wiki-link parser, code/escape exclusion, non-blocking warnings, edge-case tests |
| **Scope creep** (attachments, sync, PDF, study tools) | Kept out of v1 (§4); data model already leaves room (no path/filename coupling, nullable `linkType`, stable IDs) |
| **Force-directed layout quality** | Bounded iterations, seeded determinism, fallback to a simple radial/neighbor layout if physics proves flaky |
| **Solo-dev schedule slip** | Estimate after Phase 1 feasibility work, use phase gates, defer optional polish before data safety or core linking |

## 14. Acceptance Criteria (v1)

- [ ] A user can create and edit notes fully offline, close the app, and find the saved notes after reopening.
- [ ] A force-kill test confirms committed edits survive; the editor reports saving/error accurately and documents the possible loss of uncommitted edits.
- [ ] A user can organize notes with folders and tags (multiple tags per note).
- [ ] Search finds text in both titles and content, with filters and highlighted excerpts.
- [ ] A user can link two notes via `[[...]]`, see the outgoing link on the source and the backlink on the target, and open the target.
- [ ] Renaming a linked note and having duplicate note titles do not change a link's target ID (verified by test and by hand).
- [ ] Broken links are visible and repairable.
- [ ] The graph shows linked notes; users can pan, zoom, select a node, expand one ring, and open the note; a list-based alternative exists.
- [ ] Deleted notes are recoverable from trash; purge requires double confirmation.
- [ ] A user can export all notes (zip + Markdown + metadata) and restore them on a fresh install without losing or duplicating content, hierarchy, tags, links, note states, or settings.
- [ ] Invalid archives and restore conflicts cannot partially overwrite the current vault; a merge into a populated vault is tested.
- [ ] Core screens work on small and large phone sizes with the keyboard open, on both iOS and Android.
- [ ] Upgrading from an older schema version preserves all data.

## 15. Success Measures

- First note created within a minute of install, no setup required.
- Notes reliably found via search or navigation (no "where did I put that").
- Links created and followed routinely; graph used to explore connections.
- Graph remains responsive and understandable for a personal collection (hundreds of notes).
- Users can export and restore their notes successfully at least once without assistance.

## 16. Post-MVP Roadmap (unscheduled)

- Attachments and images (model is already path-agnostic for this).
- Richer import (HTML, other note apps).
- PDF export; link types; graph hub/degree analytics.
- More graph layouts (radial, dagre-style hierarchical if a Dart port appears) and display controls.
- Study-oriented tools: flashcards, spaced-review prompts built on links.
- Optional cross-device sync — only if the product direction demands it; the repository boundary and stable IDs are already positioned for it.
