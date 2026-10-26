import 'package:drift/drift.dart';
import 'package:spydr_notes/data/database/app_database.dart';
import 'package:spydr_notes/domain/models/tag_record.dart';
import 'package:spydr_notes/domain/repositories/tag_repository.dart';
import 'package:uuid/uuid.dart';

class DriftTagRepository implements TagRepository {
  DriftTagRepository(this._database);

  final AppDatabase _database;
  static const _uuid = Uuid();

  @override
  Future<TagRecord> createTag(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ArgumentError.value(name, 'name');
    final id = _uuid.v4();
    await _database
        .into(_database.tags)
        .insert(TagsCompanion.insert(id: id, name: trimmed));
    return (await findById(id))!;
  }

  @override
  Future<TagRecord?> findById(String id) async {
    final row = await (_database.select(
      _database.tags,
    )..where((tag) => tag.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toRecord(row);
  }

  @override
  Future<List<TagRecord>> listTags() async {
    final rows = await (_database.select(
      _database.tags,
    )..orderBy([(tag) => OrderingTerm.asc(tag.name)])).get();
    return rows.map(_toRecord).toList();
  }

  static TagRecord _toRecord(Tag row) => TagRecord(id: row.id, name: row.name);
}
