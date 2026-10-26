import 'package:drift/drift.dart';
import 'package:spydr_notes/data/database/app_database.dart';
import 'package:spydr_notes/domain/models/link_record.dart';
import 'package:spydr_notes/domain/repositories/link_repository.dart';

class DriftLinkRepository implements LinkRepository {
  DriftLinkRepository(this._database);

  final AppDatabase _database;

  @override
  Future<void> replaceOutgoing(String sourceNoteId, List<LinkRecord> links) {
    final positions = <int>{};
    for (final link in links) {
      if (link.sourceNoteId != sourceNoteId ||
          link.occurrenceIndex < 0 ||
          !positions.add(link.occurrenceIndex)) {
        throw ArgumentError('Invalid outgoing link occurrence');
      }
    }
    return _database.transaction(() async {
      await (_database.delete(
        _database.noteLinks,
      )..where((link) => link.sourceNoteId.equals(sourceNoteId))).go();
      for (final link in links) {
        await _database
            .into(_database.noteLinks)
            .insert(
              NoteLinksCompanion.insert(
                sourceNoteId: sourceNoteId,
                occurrenceIndex: link.occurrenceIndex,
                targetNoteId: Value(link.targetNoteId),
                targetIdText: Value(link.targetIdText),
                rawTitle: link.rawTitle,
              ),
            );
      }
    });
  }

  @override
  Future<List<LinkRecord>> outgoing(String sourceNoteId) async {
    final rows =
        await (_database.select(_database.noteLinks)
              ..where((link) => link.sourceNoteId.equals(sourceNoteId))
              ..orderBy([(link) => OrderingTerm.asc(link.occurrenceIndex)]))
            .get();
    return rows.map(_toRecord).toList();
  }

  @override
  Future<List<LinkRecord>> backlinks(String targetNoteId) async {
    final rows =
        await (_database.select(_database.noteLinks)
              ..where((link) => link.targetNoteId.equals(targetNoteId))
              ..orderBy([(link) => OrderingTerm.asc(link.sourceNoteId)]))
            .get();
    return rows.map(_toRecord).toList();
  }

  static LinkRecord _toRecord(NoteLink row) => LinkRecord(
    sourceNoteId: row.sourceNoteId,
    occurrenceIndex: row.occurrenceIndex,
    targetNoteId: row.targetNoteId,
    targetIdText: row.targetIdText,
    rawTitle: row.rawTitle,
  );
}
