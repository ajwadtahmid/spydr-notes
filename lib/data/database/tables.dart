import 'package:drift/drift.dart';

// rowId is a local SQLite key for FTS5. UUIDs are the portable identity.
class Notes extends Table {
  IntColumn get rowId => integer().autoIncrement()();
  TextColumn get id => text().unique()();
  TextColumn get title => text()();
  TextColumn get content => text().withDefault(const Constant(''))();
  TextColumn get folderId =>
      text().nullable().references(Folders, #id, onDelete: KeyAction.setNull)();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get lastOpenedAt => dateTime().nullable()();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

class Folders extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get parentFolderId =>
      text().nullable().references(Folders, #id, onDelete: KeyAction.setNull)();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique()();

  @override
  Set<Column> get primaryKey => {id};
}

class NoteTags extends Table {
  TextColumn get noteId =>
      text().references(Notes, #id, onDelete: KeyAction.cascade)();
  TextColumn get tagId =>
      text().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {noteId, tagId};
}

// Derived from Markdown; rebuilt when note content changes.
class NoteLinks extends Table {
  @ReferenceName('outgoingLinks')
  TextColumn get sourceNoteId =>
      text().references(Notes, #id, onDelete: KeyAction.cascade)();
  IntColumn get occurrenceIndex => integer()();
  @ReferenceName('incomingLinks')
  TextColumn get targetNoteId =>
      text().nullable().references(Notes, #id, onDelete: KeyAction.setNull)();
  TextColumn get targetIdText => text().nullable()();
  TextColumn get rawTitle => text()();
  TextColumn get linkType => text().nullable()();

  @override
  Set<Column> get primaryKey => {sourceNoteId, occurrenceIndex};
}

class SearchQueries extends Table {
  TextColumn get query => text()();
  DateTimeColumn get searchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {query};
}

class AppPreferences extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
