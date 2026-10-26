import 'package:flutter/material.dart';
import 'package:spydr_notes/presentation/screens/graph_screen.dart';
import 'package:spydr_notes/presentation/screens/notes_screen.dart';
import 'package:spydr_notes/presentation/screens/search_screen.dart';
import 'package:spydr_notes/presentation/widgets/quick_capture_dialog.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  var _selectedIndex = 0;

  static const _titles = ['Notes', 'Graph', 'Search'];
  static const _screens = [NotesScreen(), GraphScreen(), SearchScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_selectedIndex])),
      body: IndexedStack(index: _selectedIndex, children: _screens),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => const QuickCaptureDialog(),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New note'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.notes_outlined),
            label: 'Notes',
          ),
          NavigationDestination(icon: Icon(Icons.hub_outlined), label: 'Graph'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
        ],
      ),
    );
  }
}
