import 'package:drift/drift.dart';
import 'package:spydr_notes/data/database/app_database.dart';
import 'package:spydr_notes/domain/models/note_record.dart';
import 'package:spydr_notes/domain/repositories/note_repository.dart';
import 'package:uuid/uuid.dart';

class DriftNoteRepository implements NoteRepository {
  DriftNoteRepository(this._database);

  final AppDatabase _database;
  static const _uuid = Uuid();

  @override
  Stream<List<NoteRecord>> watchActiveNotes() {
    final query = _database.select(_database.notes)
      ..where((note) => note.deletedAt.isNull() & note.isArchived.equals(false))
      ..orderBy([(note) => OrderingTerm.desc(note.updatedAt)]);
    return query.watch().map((rows) => rows.map(_toRecord).toList());
  }

  @override
  Future<String> createNote({
    required String title,
    required String content,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();
    await _database
        .into(_database.notes)
        .insert(
          NotesCompanion.insert(
            id: id,
            title: title.trim().isEmpty ? 'Untitled note' : title.trim(),
            content: Value(content),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  @override
  Future<NoteRecord?> findById(String id) async {
    final row = await (_database.select(
      _database.notes,
    )..where((note) => note.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toRecord(row);
  }

  @override
  Future<List<NoteRecord>> searchNotes(String query) async {
    final matchExpression = _literalMatchExpression(query);
    if (matchExpression.isEmpty) return [];

    final matches = await _database
        .customSelect(
          '''
      SELECT notes.id AS id
      FROM notes_fts
      JOIN notes ON notes.row_id = notes_fts.rowid
      WHERE notes_fts MATCH ?
        AND notes.deleted_at IS NULL
        AND notes.is_archived = 0
      ORDER BY bm25(notes_fts), notes.updated_at DESC
      ''',
          variables: [Variable.withString(matchExpression)],
          readsFrom: {_database.notes},
        )
        .get();
    final ids = [for (final row in matches) row.read<String>('id')];
    if (ids.isEmpty) return [];

    final notes = await (_database.select(
      _database.notes,
    )..where((note) => note.id.isIn(ids))).get();
    final byId = {for (final note in notes) note.id: _toRecord(note)};
    return ids.map((id) => byId[id]).whereType<NoteRecord>().toList();
  }

  // Treat search text as literal terms, never as user-supplied FTS syntax.
  static String _literalMatchExpression(String query) => query
      .trim()
      .split(RegExp(r'\s+'))
      .where((term) => RegExp(r'[\p{L}\p{N}]', unicode: true).hasMatch(term))
      .map((term) => '"${term.replaceAll('"', '""')}"')
      .join(' AND ');

  static NoteRecord _toRecord(Note note) => NoteRecord(
    id: note.id,
    title: note.title,
    content: note.content,
    createdAt: note.createdAt,
    updatedAt: note.updatedAt,
  );
}
