import 'dart:async';

import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';

import '../router.dart';

/// Handles Android share sheet intents for both warm opens and cold starts.
/// Extracts shared URLs and pushes the import route with the URL as an extra.
class IntentHandler {
  StreamSubscription<List<SharedFile>>? _subscription;

  void init() {
    // Warm open: app is already running when the share arrives.
    _subscription = FlutterSharingIntent.instance
        .getMediaStream()
        .listen(_handleFiles, onError: (_) {});

    // Cold start: app was not running; launched directly via share intent.
    FlutterSharingIntent.instance
        .getInitialSharing()
        .then(_handleFiles)
        .catchError((_) {});
  }

  void _handleFiles(List<SharedFile> files) {
    final url = files
        .map((f) => f.value)
        .firstWhere((v) => v != null && v.isNotEmpty, orElse: () => null);

    if (url == null) return;

    // Don't open a second import screen if one is already on the stack.
    final currentPath = appRouter.routerDelegate.currentConfiguration.uri.path;
    if (currentPath == '/import') return;

    appRouter.push('/import', extra: url);
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
