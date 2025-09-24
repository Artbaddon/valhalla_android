import '../../domain/entities/note_entity.dart';

abstract class NotesLocalDataSource {
  Future<List<NoteEntity>> getAll();
  Future<NoteEntity> create(String title, String content);
  Future<NoteEntity> update(NoteEntity note);
  Future<void> delete(String id);
}

class InMemoryNotesLocalDataSource implements NotesLocalDataSource {
  final List<NoteEntity> _store = [];
  int _counter = 0;

  @override
  Future<List<NoteEntity>> getAll() async {
    // simulate latency
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_store);
  }

  @override
  Future<NoteEntity> create(String title, String content) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final note = NoteEntity(
      id: (++_counter).toString(),
      title: title,
      content: content,
    );
    _store.add(note);
    return note;
  }

  @override
  Future<NoteEntity> update(NoteEntity note) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final idx = _store.indexWhere((n) => n.id == note.id);
    if (idx >= 0) {
      _store[idx] = note;
      return note;
    }
    throw StateError('Note not found');
  }

  @override
  Future<void> delete(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _store.removeWhere((n) => n.id == id);
  }
}
