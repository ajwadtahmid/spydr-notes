import 'package:drift/drift.dart';
import 'package:spydr_notes/data/database/app_database.dart';
import 'package:spydr_notes/domain/models/folder_record.dart';
import 'package:spydr_notes/domain/repositories/folder_repository.dart';
import 'package:uuid/uuid.dart';

class DriftFolderRepository implements FolderRepository {
  DriftFolderRepository(this._database);

  final AppDatabase _database;
  static const _uuid = Uuid();

  @override
  Future<FolderRecord> createFolder(
    String name, {
    String? parentFolderId,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ArgumentError.value(name, 'name');
    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    await _database
        .into(_database.folders)
        .insert(
          FoldersCompanion.insert(
            id: id,
            name: trimmed,
            parentFolderId: Value(parentFolderId),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return (await findById(id))!;
  }

  @override
  Future<FolderRecord?> findById(String id) async {
    final row = await (_database.select(
      _database.folders,
    )..where((folder) => folder.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toRecord(row);
  }

  @override
  Future<List<FolderRecord>> listFolders() async {
    final rows = await (_database.select(
      _database.folders,
    )..orderBy([(folder) => OrderingTerm.asc(folder.name)])).get();
    return rows.map(_toRecord).toList();
  }

  static FolderRecord _toRecord(Folder row) => FolderRecord(
    id: row.id,
    name: row.name,
    parentFolderId: row.parentFolderId,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );
}
