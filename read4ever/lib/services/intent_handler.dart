import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';

import '../router.dart';
import '../screens/import/import_screen.dart';

/// Handles Android share sheet intents for both warm opens and cold starts.
/// Extracts shared URLs and opens the import bottom sheet over the current
/// screen. If another URL is shared while the sheet is open, the sheet is
/// replaced with the new URL.
class IntentHandler {
  StreamSubscription<List<SharedFile>>? _subscription;
  String? _pendingUrl;
  bool _isSheetOpen = false;

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

    _pendingUrl = url;
    _presentPendingUrl();
  }

  void _presentPendingUrl() {
    final url = _pendingUrl;
    if (url == null) return;

    if (_isSheetOpen) {
      // Close the active sheet first, then open a fresh one with the latest URL.
      rootNavigatorKey.currentState?.pop();
      return;
    }

    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _presentPendingUrl();
      });
      return;
    }

    _pendingUrl = null;
    _isSheetOpen = true;
    showImportBottomSheet(
      context,
      initialUrl: url,
      autoDiscover: true,
    ).whenComplete(() {
      _isSheetOpen = false;
      if (_pendingUrl != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _presentPendingUrl();
        });
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
