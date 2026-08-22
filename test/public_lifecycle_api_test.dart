import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('public barrel exposes only the approved managed lifecycle surface', () {
    final runtimeFile = File('lib/src/runtime.dart');
    final barrel = File('lib/git2dart_binaries.dart').readAsStringSync();

    expect(
      runtimeFile.existsSync(),
      isTrue,
      reason: 'Gate 2 must add the approved runtime contract.',
    );
    expect(barrel, contains("export 'src/runtime.dart';"));

    final runtimeSource = runtimeFile.readAsStringSync();
    expect(runtimeSource, contains('final class Libgit2Runtime'));
    expect(runtimeSource, contains('final class Libgit2OwnerLease'));
    expect(runtimeSource, contains('libgit2Runtime'));
    expect(runtimeSource, contains('withCall'));
    expect(runtimeSource, contains('acquireOwner'));
    expect(runtimeSource, contains('shutdown'));
  });

  test('legacy lifecycle globals are not required or retained', () {
    final utilSource = File('lib/src/util.dart').readAsStringSync();

    expect(
      utilSource,
      isNot(matches(RegExp(r'^final\s+libgit2\s*=', multiLine: true))),
    );
    expect(
      utilSource,
      isNot(matches(RegExp(r'^final\s+libgit2Opts\s*=', multiLine: true))),
    );
  });

  test('raw lifecycle transitions exist only in the runtime owner', () {
    final violations = <String>[];

    for (final file in _productionDartFiles()) {
      final path = file.path.replaceAll(Platform.pathSeparator, '/');
      if (path.endsWith('/bindings.dart') || path.endsWith('/runtime.dart')) {
        continue;
      }

      final source = file.readAsStringSync();
      if (source.contains('.git_libgit2_init(') ||
          source.contains('.git_libgit2_shutdown(')) {
        violations.add(path);
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Only the package-owned runtime may change the native count.',
    );
  });
}

Iterable<File> _productionDartFiles() sync* {
  for (final entry in Directory('lib').listSync(recursive: true)) {
    if (entry is File && entry.path.endsWith('.dart')) {
      yield entry;
    }
  }
}
