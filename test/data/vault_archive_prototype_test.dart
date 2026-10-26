import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spydr_notes/data/backup/vault_archive_prototype.dart';
import 'package:spydr_notes/data/database/app_database.dart';
import 'package:spydr_notes/data/repositories/drift_folder_repository.dart';
import 'package:spydr_notes/data/repositories/drift_note_repository.dart';
import 'package:spydr_notes/data/repositories/drift_tag_repository.dart';

void main() {
  test(
    'zip export restores note content and organization to a fresh vault',
    () async {
      final source = AppDatabase(NativeDatabase.memory());
      final folder = await DriftFolderRepository(source)
          .createFolder('Courses');
      final tag = await DriftTagRepository(source).createTag('Exam');
      final noteId = await DriftNoteRepository(
        source,
      ).createNote(title: 'Physics', content: '# Gravity\nOrbits and forces');
      await (source.update(
        source.notes,
      )..where((note) => note.id.equals(noteId))).write(
        NotesCompanion(folderId: Value(folder.id), isPinned: const Value(true)),
      );
      await source
          .into(source.noteTags)
          .insert(NoteTagsCompanion.insert(noteId: noteId, tagId: tag.id));

      final archive = await const VaultArchivePrototype().export(source);
      await source.close();
      final target = AppDatabase(NativeDatabase.memory());
      addTearDown(target.close);
      await const VaultArchivePrototype().restoreIntoEmpty(target, archive);

      final note = (await target.select(target.notes).get()).single;
      expect(note.id, noteId);
      expect(note.folderId, folder.id);
      expect(note.content, '# Gravity\nOrbits and forces');
      expect(note.isPinned, isTrue);
      expect((await target.select(target.tags).get()).single.id, tag.id);
      expect((await target.select(target.noteTags).get()).single.tagId, tag.id);
      expect(
        (await DriftNoteRepository(target).searchNotes('orbits')).single.id,
        noteId,
      );
    },
  );

  test('invalid input and nonempty target leave the vault unchanged', () async {
    final source = AppDatabase(NativeDatabase.memory());
    await DriftNoteRepository(source)
        .createNote(title: 'Source', content: 'body');
    final archive = await const VaultArchivePrototype().export(source);
    await source.close();
    final target = AppDatabase(NativeDatabase.memory());
    addTearDown(target.close);
    final corrupted = Uint8List.fromList(archive)..[0] = 0;

    await expectLater(
      const VaultArchivePrototype().restoreIntoEmpty(target, archive),
      completes,
    );
    await expectLater(
      const VaultArchivePrototype().restoreIntoEmpty(target, archive),
      throwsStateError,
    );
    await expectLater(
      const VaultArchivePrototype().restoreIntoEmpty(target, corrupted),
      throwsA(isA<Exception>()),
    );
    expect(await target.select(target.notes).get(), hasLength(1));
  });
}
