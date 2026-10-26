class LinkRecord {
  const LinkRecord({
    required this.sourceNoteId,
    required this.occurrenceIndex,
    required this.rawTitle,
    this.targetNoteId,
    this.targetIdText,
  });

  final String sourceNoteId;
  final int occurrenceIndex;
  final String rawTitle;
  final String? targetNoteId;
  final String? targetIdText;
}
