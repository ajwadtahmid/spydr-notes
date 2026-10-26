import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spydr_notes/data/database/app_database.dart';
import 'package:spydr_notes/data/repositories/drift_note_repository.dart';

void main() {
  late AppDatabase database;
  late DriftNoteRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftNoteRepository(database);
  });
  tearDown(() async => database.close());

  test('persists notes and keeps FTS5 in sync with edits', () async {
    final id = await repository.createNote(
      title: 'Physics',
      content: 'Gravity and orbits',
    );

    expect((await repository.watchActiveNotes().first).single.id, id);
    expect((await repository.searchNotes('orbits')).single.id, id);

    await (database.update(database.notes)..where((note) => note.id.equals(id)))
        .write(const NotesCompanion(content: Value('Motion and forces')));

    expect(await repository.searchNotes('orbits'), isEmpty);
    expect((await repository.searchNotes('forces')).single.id, id);
  });

  test('treats query operators as literal text', () async {
    await repository.createNote(title: 'A "quoted" note', content: 'C++');
    expect(await repository.searchNotes('"quoted"'), hasLength(1));
    expect(await repository.searchNotes('???'), isEmpty);
  });

  test('purging a target preserves the broken link reference', () async {
    final sourceId = await repository.createNote(title: 'Source', content: '');
    final targetId = await repository.createNote(title: 'Target', content: '');
    await database
        .into(database.noteLinks)
        .insert(
          NoteLinksCompanion.insert(
            sourceNoteId: sourceId,
            occurrenceIndex: 0,
            targetNoteId: Value(targetId),
            targetIdText: Value(targetId),
            rawTitle: 'Target',
          ),
        );

    await (database.delete(
      database.notes,
    )..where((note) => note.id.equals(targetId))).go();

    final link = (await database.select(database.noteLinks).get()).single;
    expect(link.targetNoteId, isNull);
    expect(link.targetIdText, targetId);
  });
}
