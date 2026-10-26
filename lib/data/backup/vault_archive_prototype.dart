import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' show Value;
import 'package:spydr_notes/data/database/app_database.dart';

/// Phase 1 archive proof. Restore is deliberately limited to an empty vault.
/// Full conflict handling and link-index rebuilding belong to later phases.
class VaultArchivePrototype {
  const VaultArchivePrototype();

  static const _formatVersion = 1;
  static final _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  Future<Uint8List> export(AppDatabase database) async {
    final notes = await database.select(database.notes).get();
    final folders = await database.select(database.folders).get();
    final tags = await database.select(database.tags).get();
    final noteTags = await database.select(database.noteTags).get();
    final archive = Archive();

    final noteMetadata = <Map<String, Object?>>[];
    for (final note in notes) {
      final body = utf8.encode(note.content);
      archive.addFile(ArchiveFile.bytes('notes/${note.id}.md', body));
      noteMetadata.add({
        'id': note.id,
        'title': note.title,
        'folderId': note.folderId,
        'createdAt': note.createdAt.toIso8601String(),
        'updatedAt': note.updatedAt.toIso8601String(),
        'lastOpenedAt': note.lastOpenedAt?.toIso8601String(),
        'isPinned': note.isPinned,
        'isArchived': note.isArchived,
        'deletedAt': note.deletedAt?.toIso8601String(),
        'sha256': sha256.convert(body).toString(),
      });
    }

    archive.addFile(
      ArchiveFile.string(
        'vault.json',
        const JsonEncoder.withIndent('  ').convert({
          'formatVersion': _formatVersion,
          'notes': noteMetadata,
          'folders': [
            for (final folder in folders)
              {
                'id': folder.id,
                'name': folder.name,
                'parentFolderId': folder.parentFolderId,
                'createdAt': folder.createdAt.toIso8601String(),
                'updatedAt': folder.updatedAt.toIso8601String(),
              },
          ],
          'tags': [
            for (final tag in tags) {'id': tag.id, 'name': tag.name},
          ],
          'noteTags': [
            for (final pair in noteTags)
              {'noteId': pair.noteId, 'tagId': pair.tagId},
          ],
        }),
      ),
    );
    return ZipEncoder().encodeBytes(archive);
  }

  Future<void> restoreIntoEmpty(AppDatabase database, Uint8List bytes) async {
    final archive = ZipDecoder().decodeBytes(bytes, verify: true);
    final manifestFile = archive.findFile('vault.json');
    if (manifestFile == null) throw const FormatException('Missing vault.json');
    final manifest = Map<String, dynamic>.from(
      jsonDecode(utf8.decode(manifestFile.readBytes()!)) as Map,
    );
    if (manifest['formatVersion'] != _formatVersion) {
      throw const FormatException('Unsupported archive version');
    }

    final notes = _entries(manifest, 'notes');
    final folders = _entries(manifest, 'folders');
    final tags = _entries(manifest, 'tags');
    final noteTags = _entries(manifest, 'noteTags');
    final noteIds = <String>{};
    final folderIds = <String>{};
    final tagIds = <String>{};
    final bodies = <String, String>{};

    for (final folder in folders) {
      final id = folder['id'] as String;
      if (!_uuidPattern.hasMatch(id) || !folderIds.add(id)) {
        throw const FormatException('Invalid or duplicate folder ID');
      }
    }
    for (final tag in tags) {
      final id = tag['id'] as String;
      if (!_uuidPattern.hasMatch(id) || !tagIds.add(id)) {
        throw const FormatException('Invalid or duplicate tag ID');
      }
    }
    for (final note in notes) {
      final id = note['id'] as String;
      if (!_uuidPattern.hasMatch(id) || !noteIds.add(id)) {
        throw const FormatException('Invalid or duplicate note ID');
      }
      final file = archive.findFile('notes/$id.md');
      if (file == null) throw FormatException('Missing note file: $id');
      final body = file.readBytes()!;
      if (sha256.convert(body).toString() != note['sha256']) {
        throw FormatException('Note checksum mismatch: $id');
      }
      bodies[id] = utf8.decode(body);
      if (note['folderId'] case final String folderId) {
        if (!folderIds.contains(folderId)) {
          throw FormatException('Missing folder: $folderId');
        }
      }
    }
    for (final folder in folders) {
      if (folder['parentFolderId'] case final String parentId) {
        if (!folderIds.contains(parentId)) {
          throw FormatException('Missing parent folder: $parentId');
        }
      }
    }
    for (final pair in noteTags) {
      if (!noteIds.contains(pair['noteId']) ||
          !tagIds.contains(pair['tagId'])) {
        throw const FormatException('Invalid note-tag reference');
      }
    }
    final expectedFiles = {
      'vault.json',
      for (final id in noteIds) 'notes/$id.md',
    };
    if (archive.files.length != expectedFiles.length ||
        archive.files.any((file) => !expectedFiles.contains(file.name))) {
      throw const FormatException('Unexpected archive entry');
    }

    await database.transaction(() async {
      if ((await database.select(database.notes).get()).isNotEmpty ||
          (await database.select(database.folders).get()).isNotEmpty ||
          (await database.select(database.tags).get()).isNotEmpty) {
        throw StateError('Restore prototype requires an empty vault');
      }

      final pending = [...folders];
      final inserted = <String>{};
      while (pending.isNotEmpty) {
        final countBefore = pending.length;
        for (final folder in [...pending]) {
          final parentId = folder['parentFolderId'] as String?;
          if (parentId != null && !inserted.contains(parentId)) continue;
          await database
              .into(database.folders)
              .insert(
                FoldersCompanion.insert(
                  id: folder['id'] as String,
                  name: folder['name'] as String,
                  parentFolderId: Value(parentId),
                  createdAt: DateTime.parse(folder['createdAt'] as String),
                  updatedAt: DateTime.parse(folder['updatedAt'] as String),
                ),
              );
          inserted.add(folder['id'] as String);
          pending.remove(folder);
        }
        if (pending.length == countBefore) {
          throw const FormatException('Folder cycle');
        }
      }
      for (final tag in tags) {
        await database
            .into(database.tags)
            .insert(
              TagsCompanion.insert(
                id: tag['id'] as String,
                name: tag['name'] as String,
              ),
            );
      }
      for (final note in notes) {
        final id = note['id'] as String;
        await database
            .into(database.notes)
            .insert(
              NotesCompanion.insert(
                id: id,
                title: note['title'] as String,
                content: Value(bodies[id]!),
                folderId: Value(note['folderId'] as String?),
                createdAt: DateTime.parse(note['createdAt'] as String),
                updatedAt: DateTime.parse(note['updatedAt'] as String),
                lastOpenedAt: Value(_optionalDate(note['lastOpenedAt'])),
                isPinned: Value(note['isPinned'] as bool),
                isArchived: Value(note['isArchived'] as bool),
                deletedAt: Value(_optionalDate(note['deletedAt'])),
              ),
            );
      }
      for (final pair in noteTags) {
        await database
            .into(database.noteTags)
            .insert(
              NoteTagsCompanion.insert(
                noteId: pair['noteId'] as String,
                tagId: pair['tagId'] as String,
              ),
            );
      }
    });
  }

  static List<Map<String, dynamic>> _entries(
    Map<String, dynamic> json,
    String key,
  ) => [
    for (final item in json[key] as List)
      Map<String, dynamic>.from(item as Map),
  ];

  static DateTime? _optionalDate(Object? value) =>
      value == null ? null : DateTime.parse(value as String);
}
