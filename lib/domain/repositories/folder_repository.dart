import 'package:spydr_notes/domain/models/folder_record.dart';

abstract interface class FolderRepository {
  Future<FolderRecord> createFolder(String name, {String? parentFolderId});

  Future<FolderRecord?> findById(String id);

  Future<List<FolderRecord>> listFolders();
}
