import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/notes_local_datasource.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesLocalDataSource _local;
  NotesRepositoryImpl(this._local);

  @override
  Future<List<NoteEntity>> getAll() => _local.getAll();

  @override
  Future<NoteEntity> create(String title, String content) =>
      _local.create(title, content);

  @override
  Future<NoteEntity> update(NoteEntity note) => _local.update(note);

  @override
  Future<void> delete(String id) => _local.delete(id);
}
