library;

import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

/// Helper class to set up SSL certificates for git2dart on Android.
///
/// Android apps need to manually configure SSL certificate locations
/// because the system certificate store is not accessible via standard paths.
///
/// ## Important: Initialization Order
///
/// You MUST call [initialize] AFTER libgit2 has been initialized. The correct
/// pattern is:
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   if (Platform.isAndroid) {
///     // Initialize libgit2 first (any Libgit2 static access will do this)
///     print('libgit2 version: ${Libgit2.version}');
///
///     // NOW initialize SSL certificates
///     final certPath = await AndroidSSLHelper.initialize();
///     Libgit2.setSSLCertLocations(file: certPath);
///   }
///
///   runApp(MyApp());
/// }
/// ```
///
/// **Why this order matters**: libgit2 initializes its SSL configuration when
/// first accessed. If you call [setSSLCertLocations] before this initialization,
/// your certificate configuration will be overwritten and HTTPS will fail.
class AndroidSSLHelper {
  static bool _initialized = false;
  static String? _certPath;

  /// Initialize SSL certificates for git2dart.
  ///
  /// This method extracts the bundled CA certificate file to the app's
  /// cache directory. You must call [Libgit2.setSSLCertLocations] with the
  /// returned path to configure libgit2 to use these certificates.
  ///
  /// **CRITICAL**: Call this AFTER libgit2 initialization! See class documentation.
  ///
  /// Example usage:
  /// ```dart
  /// // 1. Initialize libgit2 first
  /// final version = Libgit2.version; // Triggers libgit2 initialization
  ///
  /// // 2. Extract certificates
  /// final certPath = await AndroidSSLHelper.initialize();
  ///
  /// // 3. Configure SSL
  /// Libgit2.setSSLCertLocations(file: certPath);
  ///
  /// // 4. Now HTTPS operations will work
  /// final repo = Repository.clone(
  ///   url: 'https://github.com/user/repo.git',
  ///   localPath: '/path/to/local',
  /// );
  /// ```
  ///
  /// Returns the path to the extracted certificate file.
  static Future<String> initialize() async {
    if (_initialized && _certPath != null) {
      print('[AndroidSSLHelper] Already initialized: $_certPath');
      return _certPath!;
    }

    print('[AndroidSSLHelper] Starting initialization...');

    // Get the app's cache directory
    final cacheDir = await getTemporaryDirectory();
    final certFile = File('${cacheDir.path}/cacert.pem');
    print('[AndroidSSLHelper] Target cert path: ${certFile.path}');

    try {
      // Extract the CA bundle from assets
      print('[AndroidSSLHelper] Loading cert from assets...');
      final certData = await rootBundle.load(
        'packages/git2dart_binaries/assets/certs/cacert.pem',
      );
      print('[AndroidSSLHelper] Loaded ${certData.lengthInBytes} bytes');

      // Write to cache directory
      await certFile.writeAsBytes(certData.buffer.asUint8List(), flush: true);
      print('[AndroidSSLHelper] Written to ${certFile.path}');
      print('[AndroidSSLHelper] File exists: ${certFile.existsSync()}');
      print('[AndroidSSLHelper] File size: ${certFile.lengthSync()} bytes');

      _certPath = certFile.path;
      _initialized = true;

      print('[AndroidSSLHelper] ✓ Initialization complete: $_certPath');
      return _certPath!;
    } catch (e, stack) {
      print('[AndroidSSLHelper] ✗ Initialization failed: $e');
      print('[AndroidSSLHelper] Stack trace: $stack');
      rethrow;
    }
  }

  /// Get the path to the CA certificate file.
  ///
  /// Returns null if [initialize] hasn't been called yet.
  static String? get certPath => _certPath;

  /// Check if SSL certificates have been initialized.
  static bool get isInitialized => _initialized;
}
