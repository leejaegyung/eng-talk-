import 'package:flutter/foundation.dart';

/// Platform checks that also work on the web, where `dart:io`'s Platform
/// throws. On the web the device kind comes from the browser.
abstract final class PlatformInfo {
  static bool get isWeb => kIsWeb;

  /// Native app on these (the web build is never "iOS" here).
  static bool get isIOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  static bool get isMacOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

  /// Native phone/tablet app.
  static bool get isMobileApp => isIOS || isAndroid;

  /// e.g. "web (iOS)" or "macOS", for diagnostics.
  static String get label => kIsWeb
      ? 'web (${defaultTargetPlatform.name})'
      : defaultTargetPlatform.name;
}
