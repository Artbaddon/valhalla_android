import '../entities/note_entity.dart';

abstract class NotesRepository {
  Future<List<NoteEntity>> getAll();
  Future<NoteEntity> create(String title, String content);
  Future<NoteEntity> update(NoteEntity note);
  Future<void> delete(String id);
}
