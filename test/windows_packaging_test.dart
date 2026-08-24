import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('Windows packaging', () {
    test('exports OpenSSL runtime libraries with Windows artifacts', () {
      final action =
          File(
            p.join('.github', 'actions', 'build-windows', 'action.yml'),
          ).readAsStringSync();

      expect(action, contains('libcrypto*.dll'));
      expect(action, contains('libssl*.dll'));
      expect(action, contains('Copy-Item -Destination D:/export'));
      expect(action, contains('openssl_version:'));
      expect(action, contains(r'refs/tags/openssl-${{ inputs.openssl_version }}'));
      expect(action, contains('VC-WIN64A shared'));
      expect(action, isNot(contains('Get-Command openssl')));
    });

    test('bundles versioned OpenSSL runtime libraries in Flutter apps', () {
      final cmake =
          File(p.join('windows', 'CMakeLists.txt')).readAsStringSync();

      expect(cmake, contains('file(GLOB git2dart_binaries_openssl_libraries'));
      expect(cmake, contains('libcrypto*.dll'));
      expect(cmake, contains('libssl*.dll'));
      expect(cmake, isNot(contains('libcrypto-1_1-x64.dll')));
    });

    test(
      'package-root loader works in a plain Dart process',
      () async {
        final packageConfig = File('.dart_tool/package_config.json').absolute;
        expect(packageConfig.existsSync(), isTrue);

        final tempDir = await Directory.systemTemp.createTemp(
          'git2dart_binaries_windows_loader_',
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
      skip:
          _canRunWindowsLoaderTest()
              ? null
              : 'Windows loader test requires generated bindings and artifacts',
    );
  });
}

bool _canRunWindowsLoaderTest() {
  final artifactRoot = Platform.environment['GIT2DART_BINARIES_PACKAGE_ROOT'];
  final windowsRoot =
      artifactRoot == null ? 'windows' : p.join(artifactRoot, 'windows');
  return Platform.isWindows &&
      File(p.join('lib', 'src', 'bindings.dart')).existsSync() &&
      File(p.join(windowsRoot, 'libgit2.dll')).existsSync() &&
      File(p.join(windowsRoot, 'libssh2.dll')).existsSync() &&
      Directory(windowsRoot).listSync().whereType<File>().any((file) {
        final name = p.basename(file.path).toLowerCase();
        return name.startsWith('libcrypto') && name.endsWith('.dll');
      });
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
