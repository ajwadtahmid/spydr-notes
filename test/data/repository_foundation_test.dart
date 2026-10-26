import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spydr_notes/data/database/app_database.dart';
import 'package:spydr_notes/data/repositories/drift_folder_repository.dart';
import 'package:spydr_notes/data/repositories/drift_link_repository.dart';
import 'package:spydr_notes/data/repositories/drift_note_repository.dart';
import 'package:spydr_notes/data/repositories/drift_tag_repository.dart';
import 'package:spydr_notes/domain/models/link_record.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase(NativeDatabase.memory()));
  tearDown(() => database.close());

  test('folder and tag repositories create and read stable IDs', () async {
    final folders = DriftFolderRepository(database);
    final tags = DriftTagRepository(database);
    final root = await folders.createFolder('Courses');
    final child = await folders.createFolder(
      'Physics',
      parentFolderId: root.id,
    );
    final tag = await tags.createTag('Exam');

    expect((await folders.findById(child.id))!.parentFolderId, root.id);
    expect(await folders.listFolders(), hasLength(2));
    expect((await tags.findById(tag.id))!.name, 'Exam');
    expect(await tags.listTags(), hasLength(1));
  });

  test('link replacement is atomic and backlinks stay indexed', () async {
    final notes = DriftNoteRepository(database);
    final links = DriftLinkRepository(database);
    final source = await notes.createNote(title: 'Source', content: '');
    final target = await notes.createNote(title: 'Target', content: '');
    final first = LinkRecord(
      sourceNoteId: source,
      occurrenceIndex: 0,
      targetNoteId: target,
      targetIdText: target,
      rawTitle: 'Target',
    );
    await links.replaceOutgoing(source, [first]);

    expect((await links.outgoing(source)).single.targetNoteId, target);
    expect((await links.backlinks(target)).single.sourceNoteId, source);

    final invalid = LinkRecord(
      sourceNoteId: source,
      occurrenceIndex: 0,
      targetNoteId: 'missing-id',
      rawTitle: 'Missing',
    );
    await expectLater(
      links.replaceOutgoing(source, [invalid]),
      throwsA(isA<Exception>()),
    );
    expect((await links.outgoing(source)).single.targetNoteId, target);
  });
}
