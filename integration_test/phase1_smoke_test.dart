import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:spydr_notes/app/app.dart';
import 'package:spydr_notes/data/database/app_database.dart';
import 'package:spydr_notes/presentation/graph/graph_canvas.dart';
import 'package:spydr_notes/presentation/providers/note_providers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('quick capture and 100-node graph work on a device', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const SpydrNotesApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('New note'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Device note');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Device note'), findsOneWidget);

    await tester.tap(find.text('Graph').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open graph prototype'));
    await tester.pumpAndSettle();
    final canvas = find.byType(GraphCanvas);
    expect(canvas, findsOneWidget);
    await tester.tapAt(tester.getCenter(canvas));
    await tester.pumpAndSettle();
    expect(find.text('Selected: Node 0'), findsOneWidget);
    await tester.drag(canvas, const Offset(30, 20));
    await tester.pumpAndSettle();
  });
}
