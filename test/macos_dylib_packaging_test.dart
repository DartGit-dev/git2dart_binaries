import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:git2dart_binaries/src/runtime.dart';
import 'package:path/path.dart' as p;

void main() {
  test(
    'macOS dylibs are self-contained and loadable',
    () async {
      final libgit2 = File('macos/libgit2.dylib').absolute;

      expect(
        libgit2.existsSync(),
        isTrue,
        reason: '${libgit2.path} must be present in macOS artifacts',
      );

      await _expectDylibId(libgit2, '@rpath/libgit2.dylib');

      final libgit2Deps = await _otool(<String>['-L', libgit2.path]);

      expect(libgit2Deps, isNot(contains('libssh2')));
      expect(libgit2Deps, isNot(contains('libcrypto')));
      expect(libgit2Deps, isNot(contains('libssl')));

      _expectNoHomebrewReferences(libgit2Deps);

      final openedLibgit2 = ffi.DynamicLibrary.open(libgit2.path);

      expect(openedLibgit2, isA<ffi.DynamicLibrary>());

      libgit2Runtime.ensureInitialized();
      expect(libgit2Runtime.bindings, same(libgit2Runtime.bindings));
      expect(libgit2Runtime.shutdown(), greaterThanOrEqualTo(0));
    },
    skip: Platform.isMacOS ? null : 'macOS packaging test',
  );

  test(
    'macOS package-root loader works in a plain Dart process',
    () async {
      final packageConfig = File('.dart_tool/package_config.json').absolute;
      expect(
        packageConfig.existsSync(),
        isTrue,
        reason: '${packageConfig.path} must exist after pub get',
      );

      final tempDir = await Directory.systemTemp.createTemp(
        'git2dart_binaries_plain_dart_',
      );
      try {
        final script = File('${tempDir.path}/load_git2dart_binaries.dart');
        await script.writeAsString(r'''
import 'dart:io';

import 'package:git2dart_binaries/src/runtime.dart';

void main() {
  final runtime = libgit2Runtime;
  runtime.ensureInitialized();
  if (!identical(runtime.bindings, runtime.bindings) ||
      !identical(runtime.options, runtime.options)) {
    stderr.writeln('managed runtime did not reuse bindings/options');
    exit(1);
  }

  final remaining = runtime.shutdown();
  if (remaining < 0) {
    stderr.writeln('managed shutdown returned $remaining');
    exit(1);
  }
  stdout.writeln('plain-dart-libgit2-ok');
}
''');

        final result = await Process.run(
          _dartExecutable(),
          <String>['--packages=${packageConfig.path}', script.path],
          workingDirectory: Directory.current.path,
        ).timeout(const Duration(seconds: 30));

        expect(
          result.exitCode,
          0,
          reason:
              'plain Dart loader process failed or crashed.\n'
              'stdout:\n${result.stdout}\n'
              'stderr:\n${result.stderr}',
        );
        expect(result.stdout, contains('plain-dart-libgit2-ok'));
      } finally {
        await tempDir.delete(recursive: true);
      }
    },
    skip: Platform.isMacOS ? null : 'macOS plain Dart loader regression test',
  );
}

Future<void> _expectDylibId(File dylib, String expectedId) async {
  final output = await _otool(<String>['-D', dylib.path]);
  expect(output, contains(expectedId));
}

String _dartExecutable() {
  final resolved = File(Platform.resolvedExecutable).absolute;
  if (p.basenameWithoutExtension(resolved.path) == 'dart') {
    return resolved.path;
  }

  var directory = resolved.parent;
  while (directory.parent.path != directory.path) {
    final candidate = File(
      p.join(
        directory.path,
        'dart-sdk',
        'bin',
        Platform.isWindows ? 'dart.exe' : 'dart',
      ),
    );
    if (candidate.existsSync()) return candidate.path;
    directory = directory.parent;
  }
  return 'dart';
}

void _expectNoHomebrewReferences(String otoolOutput) {
  expect(otoolOutput, isNot(contains('/opt/homebrew/')));
  expect(otoolOutput, isNot(contains('/usr/local/')));
}

Future<String> _otool(List<String> arguments) async {
  final result = await Process.run('otool', arguments);
  final output = '${result.stdout}${result.stderr}';

  if (result.exitCode != 0) {
    fail('otool ${arguments.join(' ')} failed:\n$output');
  }

  return output;
}
