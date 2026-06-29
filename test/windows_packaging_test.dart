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
        expect(await packageConfig.exists(), isTrue);

        final tempDir = await Directory.systemTemp.createTemp(
          'git2dart_binaries_windows_loader_',
        );
        try {
          final script = File('${tempDir.path}/load_git2dart_binaries.dart');
          await script.writeAsString(r'''
import 'dart:io';

import 'package:git2dart_binaries/src/util.dart' as git2;

void main() {
  final initCount = git2.libgit2.git_libgit2_init();
  if (initCount < 1) {
    stderr.writeln('git_libgit2_init returned $initCount');
    exit(1);
  }

  git2.libgit2.git_libgit2_shutdown();
  git2.libgit2.git_libgit2_shutdown();
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
  return Platform.isWindows &&
      File(p.join('lib', 'src', 'bindings.dart')).existsSync() &&
      File(p.join('windows', 'libgit2.dll')).existsSync() &&
      File(p.join('windows', 'libssh2.dll')).existsSync() &&
      Directory('windows').listSync().whereType<File>().any((file) {
        final name = p.basename(file.path).toLowerCase();
        return name.startsWith('libcrypto') && name.endsWith('.dll');
      });
}

String _dartExecutable() {
  final executable = File(Platform.resolvedExecutable).uri.pathSegments.last;
  return executable == 'dart' ? Platform.resolvedExecutable : 'dart';
}
