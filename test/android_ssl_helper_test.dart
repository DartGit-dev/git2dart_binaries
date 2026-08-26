import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:git2dart_binaries/src/android_ssl_helper.dart';

void main() {
  late Directory root;
  late int directoryCalls;
  late int assetCalls;
  late int writeCalls;

  setUp(() async {
    AndroidSSLHelper.resetForTesting();
    root = await Directory.systemTemp.createTemp('android-tls-proof-');
    directoryCalls = 0;
    assetCalls = 0;
    writeCalls = 0;
  });
  tearDown(() async {
    AndroidSSLHelper.resetForTesting();
    if (root.existsSync()) await root.delete(recursive: true);
  });

  AndroidSSLDependencies dependencies({
    Object? directoryFailure,
    Object? assetFailure,
    Object? writeFailure,
  }) => AndroidSSLDependencies(
    temporaryDirectory: () async {
      directoryCalls++;
      if (directoryFailure != null) throw directoryFailure;
      return root;
    },
    loadCertificateAsset: () async {
      assetCalls++;
      if (assetFailure != null) throw assetFailure;
      return Uint8List.fromList(<int>[1, 2, 3]);
    },
    writeCertificate: (file, bytes) async {
      writeCalls++;
      if (writeFailure != null) throw writeFailure;
      await file.writeAsBytes(bytes, flush: true);
    },
  );

  test('successful initialization is cached only after write', () async {
    final deps = dependencies();
    final first = await AndroidSSLHelper.initializeWith(deps);
    final second = await AndroidSSLHelper.initializeWith(deps);

    expect(first, File('${root.path}/cacert.pem').path);
    expect(second, first);
    expect(AndroidSSLHelper.isInitialized, isTrue);
    expect(AndroidSSLHelper.certPath, first);
    expect((directoryCalls, assetCalls, writeCalls), (1, 1, 1));
  });

  for (final failure in <String>['directory', 'asset', 'write']) {
    test('$failure failure remains retryable', () async {
      final failed = dependencies(
        directoryFailure:
            failure == 'directory' ? StateError('directory') : null,
        assetFailure: failure == 'asset' ? StateError('asset') : null,
        writeFailure: failure == 'write' ? StateError('write') : null,
      );
      await expectLater(
        AndroidSSLHelper.initializeWith(failed),
        throwsStateError,
      );
      expect(AndroidSSLHelper.isInitialized, isFalse);
      expect(AndroidSSLHelper.certPath, isNull);

      final recovered = await AndroidSSLHelper.initializeWith(dependencies());
      expect(recovered, File('${root.path}/cacert.pem').path);
      expect(AndroidSSLHelper.isInitialized, isTrue);
    });
  }
}
