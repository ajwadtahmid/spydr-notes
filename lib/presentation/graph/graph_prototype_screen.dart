import 'package:flutter/material.dart';
import 'package:spydr_notes/presentation/graph/graph_canvas.dart';

class GraphPrototypeScreen extends StatefulWidget {
  const GraphPrototypeScreen({super.key});

  @override
  State<GraphPrototypeScreen> createState() => _GraphPrototypeScreenState();
}

class _GraphPrototypeScreenState extends State<GraphPrototypeScreen> {
  final _nodes = createPrototypeNodes(100);
  final _edges = [
    for (var index = 1; index < 100; index++) GraphEdge(index ~/ 2, index),
  ];
  String? _selection;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('100-node graph prototype')),
    body: Column(
      children: [
        Expanded(
          child: GraphCanvas(
            nodes: _nodes,
            edges: _edges,
            onNodeTap: (node) => setState(() => _selection = node.id),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _selection == null ? 'Tap a node' : 'Selected: $_selection',
          ),
        ),
      ],
    ),
  );
}
