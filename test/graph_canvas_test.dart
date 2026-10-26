import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spydr_notes/presentation/graph/graph_canvas.dart';

void main() {
  testWidgets('100-node canvas responds to selection and pan', (tester) async {
    final nodes = createPrototypeNodes(100);
    final edges = [
      for (var index = 1; index < 100; index++) GraphEdge(index ~/ 2, index),
    ];
    final selected = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 600,
            child: GraphCanvas(
              nodes: nodes,
              edges: edges,
              onNodeTap: (node) => selected.add(node.id),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final center = tester.getCenter(find.byType(GraphCanvas));
    await tester.tapAt(center);
    await tester.pump();
    expect(selected, ['Node 0']);

    final viewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    final before = MatrixUtils.transformPoint(
      viewer.transformationController!.value,
      const Offset(300, 300),
    );
    await tester.drag(find.byType(GraphCanvas), const Offset(30, 20));
    await tester.pumpAndSettle();
    final after = MatrixUtils.transformPoint(
      viewer.transformationController!.value,
      const Offset(300, 300),
    );
    expect(after, isNot(before));
    await tester.tapAt(
      tester.getTopLeft(find.byType(InteractiveViewer)) + after,
    );
    await tester.pump();
    expect(selected, ['Node 0', 'Node 0']);
  });
}
