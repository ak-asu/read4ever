import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';

// Placeholder router until step 2 — replaced then
final _router = MaterialPageRoute<void>(
  builder: (_) => const _PlaceholderScreen(),
);

class LearnStackApp extends ConsumerWidget {
  const LearnStackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'LearnStack',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const _PlaceholderScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'LearnStack',
              style: theme.textTheme.displayLarge,
            ),
            const SizedBox(height: 16),
            // Teal accent visible for step 1 acceptance check
            ElevatedButton(
              onPressed: () {},
              child: const Text('Getting started…'),
            ),
          ],
        ),
      ),
    );
  }
}
