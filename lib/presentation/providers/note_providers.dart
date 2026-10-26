import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spydr_notes/data/database/app_database.dart';
import 'package:spydr_notes/data/repositories/drift_note_repository.dart';
import 'package:spydr_notes/domain/models/note_record.dart';
import 'package:spydr_notes/domain/repositories/note_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => DriftNoteRepository(ref.watch(databaseProvider)),
);

final activeNotesProvider = StreamProvider<List<NoteRecord>>(
  (ref) => ref.watch(noteRepositoryProvider).watchActiveNotes(),
);
