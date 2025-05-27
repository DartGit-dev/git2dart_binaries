import 'dart:ffi';
import 'dart:io';

import 'package:git2dart_binaries/src/util.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  group('Library Loading Tests', () {
    test('Library can be loaded and initialized', () {
      expect(
        () => libgit2,
        returnsNormally,
        reason: 'libgit2 should be initialized without throwing exceptions',
      );
      expect(
        () => libgit2Opts,
        returnsNormally,
        reason: 'libgit2Opts should be initialized without throwing exceptions',
      );
    });

    test('Dependencies are loaded correctly', () {
      final libraryPath = path.dirname(Platform.resolvedExecutable);

      if (Platform.isLinux) {
        expect(
          () => DynamicLibrary.open(path.join(libraryPath, "libssh2.so")),
          returnsNormally,
          reason: 'libssh2.so should load without throwing exceptions',
        );
      } else if (Platform.isMacOS) {
        expect(
          () => DynamicLibrary.open(path.join(libraryPath, "libssh2.1.dylib")),
          returnsNormally,
          reason: 'libssh2.1.dylib should load without throwing exceptions',
        );
      } else if (Platform.isWindows) {
        expect(
          () => DynamicLibrary.open(path.join(libraryPath, "libssh2.dll")),
          returnsNormally,
          reason: 'libssh2.dll should load without throwing exceptions',
        );
      }
    });
  });
}
