import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spydr_notes/data/repositories/drift_folder_repository.dart';
import 'package:spydr_notes/data/repositories/drift_link_repository.dart';
import 'package:spydr_notes/data/repositories/drift_tag_repository.dart';
import 'package:spydr_notes/domain/repositories/folder_repository.dart';
import 'package:spydr_notes/domain/repositories/link_repository.dart';
import 'package:spydr_notes/domain/repositories/tag_repository.dart';
import 'package:spydr_notes/presentation/providers/note_providers.dart';

final folderRepositoryProvider = Provider<FolderRepository>(
  (ref) => DriftFolderRepository(ref.watch(databaseProvider)),
);

final tagRepositoryProvider = Provider<TagRepository>(
  (ref) => DriftTagRepository(ref.watch(databaseProvider)),
);

final linkRepositoryProvider = Provider<LinkRepository>(
  (ref) => DriftLinkRepository(ref.watch(databaseProvider)),
);
