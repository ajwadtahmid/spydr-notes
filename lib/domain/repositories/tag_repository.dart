import 'package:spydr_notes/domain/models/tag_record.dart';

abstract interface class TagRepository {
  Future<TagRecord> createTag(String name);

  Future<TagRecord?> findById(String id);

  Future<List<TagRecord>> listTags();
}
