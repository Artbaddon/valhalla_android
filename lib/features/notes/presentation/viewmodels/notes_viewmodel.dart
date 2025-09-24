import 'package:flutter/material.dart';
import '../../../notes/domain/entities/note_entity.dart';
import '../../../notes/domain/repositories/notes_repository.dart';

class NotesViewModel extends ChangeNotifier {
  final NotesRepository _repo;
  NotesViewModel(this._repo);

  List<NoteEntity> _notes = [];
  bool _loading = false;
  String? _error;

  List<NoteEntity> get notes => _notes;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _notes = await _repo.getAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> add(String title, String content) async {
    await _repo.create(title, content);
    await load();
  }

  Future<void> update(NoteEntity note) async {
    await _repo.update(note);
    await load();
  }

  Future<void> remove(String id) async {
    await _repo.delete(id);
    await load();
  }
}
