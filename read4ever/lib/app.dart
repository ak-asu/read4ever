import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'router.dart';
import 'providers/theme_provider.dart';
import 'services/intent_handler.dart';

class LearnStackApp extends ConsumerStatefulWidget {
  const LearnStackApp({super.key});

  @override
  ConsumerState<LearnStackApp> createState() => _LearnStackAppState();
}

class _LearnStackAppState extends ConsumerState<LearnStackApp> {
  late final IntentHandler _intentHandler;

  @override
  void initState() {
    super.initState();
    _intentHandler = IntentHandler();
    _intentHandler.init();
  }

  @override
  void dispose() {
    _intentHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);
    return MaterialApp.router(
      title: 'LearnStack',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
