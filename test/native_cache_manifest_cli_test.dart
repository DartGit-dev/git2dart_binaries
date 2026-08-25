import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'support/behavior_proof_fixture.dart';

void main() {
  late BehaviorProofFixture fixture;
  late Directory exportRoot;
  late File manifest;

  setUp(() async {
    fixture = await BehaviorProofFixture.create('native-cache-cli-');
    exportRoot = Directory(p.join(fixture.root.path, 'export'))..createSync();
    File(
      p.join(exportRoot.path, 'payload.bin'),
    ).writeAsBytesSync(<int>[1, 2, 3]);
    manifest = fixture.file('manifest.json');
    final created = await _run(fixture, 'create', manifest, exportRoot);
    expect(created.exitCode, 0, reason: '${created.stdout}\n${created.stderr}');
  });
  tearDown(() => fixture.dispose());

  test('valid manifest validates through the public CLI', () async {
    final result = await _run(fixture, 'validate', manifest, exportRoot);
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
  });

  for (final corruption in <String>[
    'metadata',
    'file-list',
    'digest-size',
    'provenance',
    'unsafe-path',
    'malformed-json',
    'unreadable',
  ]) {
    test(
      '$corruption manifest fails closed with sanitized diagnostics',
      () async {
        var candidate = manifest;
        if (corruption == 'malformed-json') {
          manifest.writeAsStringSync('{');
        } else if (corruption == 'unreadable') {
          candidate = File(p.join(fixture.root.path, 'manifest-directory'));
          Directory(candidate.path).createSync();
        } else {
          final record =
              jsonDecode(manifest.readAsStringSync()) as Map<String, dynamic>;
          final files = record['files'] as Map<String, dynamic>;
          switch (corruption) {
            case 'metadata':
              record['platform'] = 'other';
              break;
            case 'file-list':
              files['extra.bin'] = <String, Object>{
                'sha256': List<String>.filled(64, '0').join(),
                'size': 0,
              };
              break;
            case 'digest-size':
              (files.values.single as Map<String, dynamic>)['size'] = 999;
              break;
            case 'provenance':
              record.remove('source_ref');
              break;
            case 'unsafe-path':
              files['../escape.bin'] = files.remove('payload.bin');
              break;
          }
          manifest.writeAsStringSync(jsonEncode(record));
        }

        final result = await _run(fixture, 'validate', candidate, exportRoot);
        expect(result.exitCode, isNot(0));
        expect(result.stderr, contains('Native cache validation failed:'));
        expect(result.stderr, isNot(contains(fixture.root.absolute.path)));
      },
    );
  }
}

Future<ProcessResult> _run(
  BehaviorProofFixture fixture,
  String command,
  File manifest,
  Directory exportRoot,
) => fixture.runBounded(_pythonExecutable(), <String>[
  File('.github/scripts/native_cache_manifest.py').absolute.path,
  command,
  '--manifest',
  manifest.path,
  '--export-root',
  exportRoot.path,
  '--platform',
  'test',
  '--abi',
  'x64',
  '--libgit2',
  '1.9.6',
  '--libssh2',
  '1.11.1',
  '--openssl',
  '3.0.15',
  '--toolchain',
  'fixture',
  '--provenance',
  'source-build',
  '--source-ref',
  'refs/tags/v1.9.6',
]);

String _pythonExecutable() => Platform.isWindows ? 'python' : 'python3';
