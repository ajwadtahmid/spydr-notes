import 'package:flutter/material.dart';
import 'package:spydr_notes/app/router/app_shell.dart';
import 'package:spydr_notes/app/theme/app_theme.dart';

class SpydrNotesApp extends StatelessWidget {
  const SpydrNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpydrNotes',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const AppShell(),
    );
  }
}
