import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spydr_notes/app/app.dart';
import 'package:spydr_notes/data/database/app_database.dart';
import 'package:spydr_notes/presentation/providers/note_providers.dart';

void main() {
  testWidgets('quick capture appears in the notes list', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const SpydrNotesApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('No notes yet. Tap New note to capture an idea.'),
      findsOneWidget,
    );
    await tester.tap(find.text('New note'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Physics');
    await tester.enterText(find.byType(TextField).at(1), 'Gravity and orbits');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Physics'), findsOneWidget);
    expect(find.text('Gravity and orbits'), findsOneWidget);

    // Let Drift cancel its watched query before the test clock is inspected.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
