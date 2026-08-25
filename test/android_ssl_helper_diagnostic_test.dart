import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:git2dart_binaries/src/android_ssl_helper.dart';

void main() {
  test(
    'temporary-directory failure is observable and does not cache success',
    () async {
      AndroidSSLHelper.resetForTesting();
      addTearDown(AndroidSSLHelper.resetForTesting);
      final dependencies = AndroidSSLDependencies(
        temporaryDirectory:
            () => throw const FileSystemException('unavailable'),
        loadCertificateAsset: () => throw StateError('must not load'),
        writeCertificate: (_, _) => throw StateError('must not write'),
      );

      await expectLater(
        AndroidSSLHelper.initializeWith(dependencies),
        throwsA(isA<FileSystemException>()),
      );
      expect(AndroidSSLHelper.isInitialized, isFalse);
      expect(AndroidSSLHelper.certPath, isNull);
    },
  );
}
