import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../notes/presentation/viewmodels/notes_viewmodel.dart';
import '../../../notes/domain/entities/note_entity.dart';

class NotesListPage extends StatelessWidget {
  const NotesListPage({super.key});
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotesViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: vm.notes.length,
              itemBuilder: (_, i) {
                final n = vm.notes[i];
                return ListTile(
                  title: Text(n.title),
                  subtitle: Text(n.content),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => vm.remove(n.id),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => NoteEditPage(note: n)),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NoteEditPage()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NoteEditPage extends StatefulWidget {
  final NoteEntity? note;
  const NoteEditPage({super.key, this.note});
  @override
  State<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _title;
  late TextEditingController _content;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.note?.title ?? '');
    _content = TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<NotesViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _content,
                decoration: const InputDecoration(labelText: 'Content'),
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  if (widget.note == null) {
                    await vm.add(_title.text, _content.text);
                  } else {
                    await vm.update(
                      NoteEntity(
                        id: widget.note!.id,
                        title: _title.text,
                        content: _content.text,
                      ),
                    );
                  }
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
