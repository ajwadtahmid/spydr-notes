import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:spydr_notes/data/database/tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Notes,
    Folders,
    Tags,
    NoteTags,
    NoteLinks,
    SearchQueries,
    AppPreferences,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'spydr_notes'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await _createSearchIndex();
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _createSearchIndex() async {
    await customStatement('''
      CREATE VIRTUAL TABLE notes_fts USING fts5(
        title, content, content='notes', content_rowid='row_id'
      )
    ''');
    await customStatement('''
      CREATE TRIGGER notes_ai AFTER INSERT ON notes BEGIN
        INSERT INTO notes_fts(rowid, title, content)
        VALUES (new.row_id, new.title, new.content);
      END
    ''');
    await customStatement('''
      CREATE TRIGGER notes_ad AFTER DELETE ON notes BEGIN
        INSERT INTO notes_fts(notes_fts, rowid, title, content)
        VALUES ('delete', old.row_id, old.title, old.content);
      END
    ''');
    await customStatement('''
      CREATE TRIGGER notes_au AFTER UPDATE OF title, content ON notes BEGIN
        INSERT INTO notes_fts(notes_fts, rowid, title, content)
        VALUES ('delete', old.row_id, old.title, old.content);
        INSERT INTO notes_fts(rowid, title, content)
        VALUES (new.row_id, new.title, new.content);
      END
    ''');
  }
}
