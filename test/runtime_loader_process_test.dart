import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'support/behavior_proof_fixture.dart';

void main() {
  late BehaviorProofFixture fixture;
  setUp(
    () async => fixture = await BehaviorProofFixture.create('loader-proof-'),
  );
  tearDown(() => fixture.dispose());

  test(
    'desktop terminal failure reports bare and package fallback attempts',
    () async {
      final emptyRoot = Directory(p.join(fixture.root.path, 'empty-package'))
        ..createSync();
      final result = await _runProbe(fixture, emptyRoot.path, 'load');

      expect(result.exitCode, isNot(0));
      expect(result.stderr, contains('Failed to open libgit2. Tried:'));
      expect(result.stderr, contains(_libraryName()));
      expect(result.stderr, contains('<fixture-root>'));
      expect(result.stderr, isNot(contains(fixture.root.absolute.path)));
    },
  );

  test('desktop package-root fallback loads an injected payload', () async {
    final packageRoot = Platform.environment['GIT2DART_BINARIES_PACKAGE_ROOT'];
    if (packageRoot == null || !_hasPayload(packageRoot)) {
      stdout.writeln(
        'loader-evidence: unavailable (no declared native package payload)',
      );
      return;
    }
    final result = await _runProbe(fixture, packageRoot, 'load');
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    final record =
        jsonDecode((result.stdout as String).trim()) as Map<String, dynamic>;
    expect(record['status'], 'loaded');
  });

  test('Android plan has no desktop package-root fallback', () async {
    final result = await _runProbe(fixture, fixture.root.path, 'android-plan');
    expect(result.exitCode, 0, reason: result.stderr.toString());
    final record =
        jsonDecode((result.stdout as String).trim()) as Map<String, dynamic>;
    expect(record, containsPair('library', 'libgit2.so'));
    expect(record, containsPair('package_fallback', false));
  });
}

Future<ProcessResult> _runProbe(
  BehaviorProofFixture fixture,
  String packageRoot,
  String mode,
) => fixture.runBounded(
  dartExecutable(),
  <String>[
    '--packages=${File('.dart_tool/package_config.json').absolute.path}',
    File('test/fixtures/loader_probe.dart').absolute.path,
    mode,
  ],
  environment: <String, String>{
    'GIT2DART_BINARIES_PACKAGE_ROOT': packageRoot,
    if (Platform.isWindows)
      'PATH':
          Platform.environment['SystemRoot'] == null
              ? ''
              : p.join(Platform.environment['SystemRoot']!, 'System32'),
    if (!Platform.isWindows) 'LD_LIBRARY_PATH': '',
    if (Platform.isMacOS) 'DYLD_LIBRARY_PATH': '',
  },
);

String _libraryName() =>
    Platform.isWindows
        ? 'libgit2.dll'
        : Platform.isMacOS
        ? 'libgit2.dylib'
        : 'libgit2.so';

bool _hasPayload(String root) {
  final subdirectory =
      Platform.isWindows
          ? 'windows'
          : Platform.isMacOS
          ? 'macos'
          : 'linux';
  return File(p.join(root, subdirectory, _libraryName())).existsSync();
}
