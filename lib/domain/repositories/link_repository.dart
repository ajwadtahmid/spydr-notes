import 'package:spydr_notes/domain/models/link_record.dart';

abstract interface class LinkRepository {
  // The Markdown parser supplies every outgoing occurrence after a note edit.
  Future<void> replaceOutgoing(String sourceNoteId, List<LinkRecord> links);

  Future<List<LinkRecord>> outgoing(String sourceNoteId);

  Future<List<LinkRecord>> backlinks(String targetNoteId);
}
