import 'package:flutter/material.dart';
import 'package:spydr_notes/domain/models/note_record.dart';

Future<void> showNotePreview(BuildContext context, NoteRecord note) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(note.title),
      content: SingleChildScrollView(child: Text(note.content)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}
