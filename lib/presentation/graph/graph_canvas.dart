import 'dart:math' as math;

import 'package:flutter/material.dart';

class GraphNode {
  const GraphNode(this.id, this.position);

  final String id;
  final Offset position;
}

class GraphEdge {
  const GraphEdge(this.sourceIndex, this.targetIndex);

  final int sourceIndex;
  final int targetIndex;
}

/// Phase 1 rendering spike. Phase 4 will supply real vault data and layout.
class GraphCanvas extends StatefulWidget {
  const GraphCanvas({
    super.key,
    required this.nodes,
    required this.edges,
    required this.onNodeTap,
  });

  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final ValueChanged<GraphNode> onNodeTap;

  @override
  State<GraphCanvas> createState() => _GraphCanvasState();
}

class _GraphCanvasState extends State<GraphCanvas> {
  static const _canvasSize = 600.0;
  static const _nodeRadius = 7.0;
  final _transform = TransformationController();
  var _configured = false;
  int? _selectedIndex;

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!_configured &&
            constraints.hasBoundedWidth &&
            constraints.hasBoundedHeight) {
          _configured = true;
          final scale = math.min(
            constraints.maxWidth / _canvasSize,
            constraints.maxHeight / _canvasSize,
          );
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _transform.value = Matrix4.identity()
              ..translateByDouble(
                (constraints.maxWidth - _canvasSize * scale) / 2,
                (constraints.maxHeight - _canvasSize * scale) / 2,
                0,
                1,
              )
              ..scaleByDouble(scale, scale, 1, 1);
          });
        }
        return InteractiveViewer(
          transformationController: _transform,
          constrained: false,
          minScale: 0.3,
          maxScale: 4,
          boundaryMargin: const EdgeInsets.all(240),
          child: SizedBox(
            width: _canvasSize,
            height: _canvasSize,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) {
                for (var index = widget.nodes.length - 1; index >= 0; index--) {
                  final node = widget.nodes[index];
                  if ((node.position - details.localPosition).distance <=
                      _nodeRadius + 5) {
                    setState(() => _selectedIndex = index);
                    widget.onNodeTap(node);
                    break;
                  }
                }
              },
              child: CustomPaint(
                painter: _GraphPainter(
                  nodes: widget.nodes,
                  edges: widget.edges,
                  selectedIndex: _selectedIndex,
                  colors: colors,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GraphPainter extends CustomPainter {
  const _GraphPainter({
    required this.nodes,
    required this.edges,
    required this.selectedIndex,
    required this.colors,
  });

  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final int? selectedIndex;
  final ColorScheme colors;

  @override
  void paint(Canvas canvas, Size size) {
    final edgePaint = Paint()
      ..color = colors.outlineVariant
      ..strokeWidth = 1.5;
    for (final edge in edges) {
      canvas.drawLine(
        nodes[edge.sourceIndex].position,
        nodes[edge.targetIndex].position,
        edgePaint,
      );
    }
    final nodePaint = Paint()..color = colors.primary;
    for (var index = 0; index < nodes.length; index++) {
      nodePaint.color = index == selectedIndex
          ? colors.tertiary
          : colors.primary;
      canvas.drawCircle(
        nodes[index].position,
        index == selectedIndex ? 11 : 7,
        nodePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GraphPainter oldDelegate) =>
      !identical(nodes, oldDelegate.nodes) ||
      !identical(edges, oldDelegate.edges) ||
      selectedIndex != oldDelegate.selectedIndex ||
      colors != oldDelegate.colors;
}

List<GraphNode> createPrototypeNodes(int count) {
  assert(count > 0);
  return [
    const GraphNode('Node 0', Offset(300, 300)),
    for (var index = 1; index < count; index++)
      GraphNode(
        'Node $index',
        Offset(
          300 + 235 * math.sqrt(index / count) * math.cos(index * 2.399963),
          300 + 235 * math.sqrt(index / count) * math.sin(index * 2.399963),
        ),
      ),
  ];
}
