import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'router.dart';
import 'providers/theme_provider.dart';
import 'services/intent_handler.dart';

class Read4everApp extends ConsumerStatefulWidget {
  const Read4everApp({super.key});

  @override
  ConsumerState<Read4everApp> createState() => _Read4everAppState();
}

class _Read4everAppState extends ConsumerState<Read4everApp> {
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
      title: 'Read4ever',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
