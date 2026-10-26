import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spydr_notes/domain/models/note_record.dart';
import 'package:spydr_notes/presentation/providers/note_providers.dart';
import 'package:spydr_notes/presentation/widgets/note_preview_dialog.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  Future<List<NoteRecord>>? _results;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _search(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _results = value.trim().isEmpty
            ? null
            : ref.read(noteRepositoryProvider).searchNotes(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _controller,
            onChanged: _search,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search notes',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: _results == null
              ? const Center(child: Text('Search note titles and content.'))
              : FutureBuilder<List<NoteRecord>>(
                  future: _results,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Search failed: ${snapshot.error}'),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final notes = snapshot.data!;
                    if (notes.isEmpty) {
                      return const Center(child: Text('No matching notes.'));
                    }
                    return ListView.builder(
                      itemCount: notes.length,
                      itemBuilder: (context, index) => ListTile(
                        title: Text(notes[index].title),
                        subtitle: Text(
                          notes[index].content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => showNotePreview(context, notes[index]),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
