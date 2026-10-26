import 'package:spydr_notes/domain/models/note_record.dart';

abstract interface class NoteRepository {
  Stream<List<NoteRecord>> watchActiveNotes();

  Future<String> createNote({required String title, required String content});

  Future<List<NoteRecord>> searchNotes(String query);
}
