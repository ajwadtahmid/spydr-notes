import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spydr_notes/presentation/graph/graph_prototype_screen.dart';

class GraphScreen extends StatelessWidget {
  const GraphScreen({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'The graph view will appear here when note linking is built.',
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const GraphPrototypeScreen(),
                ),
              ),
              child: const Text('Open graph prototype'),
            ),
          ],
        ],
      ),
    ),
  );
}
