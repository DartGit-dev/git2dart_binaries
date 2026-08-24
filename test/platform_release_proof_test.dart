import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  final script = File('.github/scripts/platform_release_proof.py');

  test('platform proof schema is sanitized and fails closed', () {
    final source = script.readAsStringSync();
    expect(source, contains('SCHEMA = "platform-release-proof/v1"'));
    expect(source, contains('FAILURE_CODES'));
    expect(source, contains('invalid-path'));
    expect(source, contains('version-unreadable'));
    expect(source, contains('unavailable'));
    expect(source, contains('safe_relative'));
    expect(source, contains('sha256'));
  });

  test(
    'source-only candidate writes non-qualifying JSON and Markdown proof',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'platform-proof-source-',
      );
      final output = Directory('${root.path}${Platform.pathSeparator}proof');
      try {
        final result = await Process.run('python', <String>[
          script.path,
          'create',
          '--platform',
          'linux',
          '--root',
          root.path,
          '--output',
          output.path,
          '--candidate',
          'fixture',
          '--libgit2',
          '1.9.6',
          '--libssh2',
          '1.11.1',
          '--openssl',
          '3.0.15',
        ]);
        expect(result.exitCode, isNot(0));
        final record =
            jsonDecode(
                  File(
                    '${output.path}${Platform.pathSeparator}proof.json',
                  ).readAsStringSync(),
                )
                as Map<String, dynamic>;
        expect(record['schema'], 'platform-release-proof/v1');
        expect(record['status'], 'failed');
        expect(record['failure_codes'], contains('missing-payload'));
        expect(record['failure_codes'], contains('version-unreadable'));
        expect(
          File(
            '${output.path}${Platform.pathSeparator}proof.md',
          ).readAsStringSync(),
          contains('Status: **failed**'),
        );
        expect(record.toString(), isNot(contains(root.path)));
      } finally {
        await root.delete(recursive: true);
      }
    },
  );

  test(
    'build-input version evidence qualifies an omitted runtime dependency',
    () async {
      final sandbox = await Directory.systemTemp.createTemp(
        'platform-proof-evidence-',
      );
      final root = Directory('${sandbox.path}${Platform.pathSeparator}payload')
        ..createSync();
      final output = Directory('${sandbox.path}${Platform.pathSeparator}proof');
      final evidence = File(
        '${sandbox.path}${Platform.pathSeparator}VERSION.dat',
      );
      try {
        File(
          '${root.path}${Platform.pathSeparator}libgit2.so',
        ).writeAsStringSync('libgit2 1.9.6');
        File(
          '${root.path}${Platform.pathSeparator}libssh2.so',
        ).writeAsStringSync('libssh2 1.11.1');
        evidence.writeAsStringSync('OPENSSL_VERSION=3.0.15');
        final result = await Process.run('python', <String>[
          script.path,
          'create',
          '--platform',
          'linux',
          '--root',
          root.path,
          '--version-evidence',
          evidence.path,
          '--output',
          output.path,
          '--candidate',
          'fixture',
          '--libgit2',
          '1.9.6',
          '--libssh2',
          '1.11.1',
          '--openssl',
          '3.0.15',
        ]);
        expect(
          result.exitCode,
          isNot(0),
          reason: 'fake shared libraries cannot load',
        );
        final record =
            jsonDecode(
                  File(
                    '${output.path}${Platform.pathSeparator}proof.json',
                  ).readAsStringSync(),
                )
                as Map<String, dynamic>;
        expect(record['failure_codes'], isNot(contains('version-unreadable')));
        expect(record['versions']['openssl']['evidence'], 'build-input');
      } finally {
        await sandbox.delete(recursive: true);
      }
    },
  );

  test(
    'aggregate gate rejects unknown schemas, failures, and missing proof scopes',
    () {
      final source = script.readAsStringSync();
      expect(source, contains('unknown schema'));
      expect(source, contains('missing {sorted(missing)}'));
      expect(source, contains('record["status"] != "passed"'));
      expect(source, contains('arm64-v8a'));
    },
  );
}
