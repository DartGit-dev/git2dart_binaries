import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'support/behavior_proof_fixture.dart';

const _scopes = <(String, String)>[
  ('linux', 'default'),
  ('macos', 'default'),
  ('windows', 'default'),
  ('ios', 'default'),
  ('android', 'x86_64'),
  ('android', 'arm64-v8a'),
  ('android', 'x86'),
  ('android', 'armeabi-v7a'),
];

const _expectedInventory = <String, List<String>>{
  'linux': <String>['libgit2.so', 'libssh2.so'],
  'macos': <String>['libgit2.dylib'],
  'windows': <String>[
    'libgit2.dll',
    'libssh2.dll',
    'libcrypto*.dll',
    'libssl*.dll',
  ],
  'android': <String>['libgit2.so', 'libssh2.so', 'libcrypto.so', 'libssl.so'],
  'ios': <String>[
    'libcrypto.xcframework/Info.plist',
    'libssl.xcframework/Info.plist',
    'libssh2.xcframework/Info.plist',
    'libgit2.xcframework/Info.plist',
  ],
};

const _abcSha256 =
    'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad';

void main() {
  late BehaviorProofFixture fixture;
  late Directory proofs;
  late Directory payload;

  setUp(() async {
    fixture = await BehaviorProofFixture.create('platform-proof-cli-');
    proofs = Directory(p.join(fixture.root.path, 'proofs'))..createSync();
    payload = Directory(p.join(fixture.root.path, 'payload'))..createSync();
    await _writeCompleteProofs(fixture, proofs, payload);
  });
  tearDown(() => fixture.dispose());

  test('complete payload-backed proof set passes the aggregate CLI', () async {
    File(
        p.join(
          payload.path,
          'macos',
          'Classes',
          'Git2dartBinariesPlugin.swift',
        ),
      )
      ..parent.createSync(recursive: true)
      ..writeAsStringSync('// checked-in plugin support, not a native payload');
    final result = await _validate(fixture, proofs, payloadRoot: payload);
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
  });

  for (final corruption in <String>[
    'invalid-schema',
    'failed-status',
    'unsafe-path',
    'malformed-json',
    'unreadable',
    'missing-scope',
    'unexpected-scope',
    'empty-inventory',
    'empty-versions',
    'null-attestation',
    'arbitrary-attestation',
    'incomplete-apple-attestation',
    'attestation-digest-mismatch',
    'payload-byte-mismatch',
  ]) {
    test('$corruption aggregate input fails closed', () async {
      final target = File(p.join(proofs.path, 'linux-default', 'proof.json'));
      final selected =
          corruption == 'incomplete-apple-attestation'
              ? File(p.join(proofs.path, 'macos-default', 'proof.json'))
              : target;
      if (corruption == 'malformed-json') {
        target.writeAsStringSync('{');
      } else if (corruption == 'unreadable') {
        target.deleteSync();
        Directory(target.path).createSync();
      } else if (corruption == 'missing-scope') {
        target.parent.deleteSync(recursive: true);
      } else if (corruption == 'payload-byte-mismatch') {
        File(
          p.join(payload.path, 'linux', 'libgit2.so'),
        ).writeAsStringSync('tampered');
      } else {
        final record =
            jsonDecode(selected.readAsStringSync()) as Map<String, dynamic>;
        switch (corruption) {
          case 'invalid-schema':
            record['schema'] = 'unknown';
            break;
          case 'failed-status':
            record['status'] = 'failed';
            record['failure_codes'] = <String>['version-mismatch'];
            break;
          case 'unsafe-path':
            (record['inventory'] as Map<String, dynamic>)['present'] = <Object>[
              <String, Object>{
                'path': '../escape.so',
                'sha256': '0',
                'size': 0,
              },
            ];
            break;
          case 'unexpected-scope':
            record['platform'] = 'freebsd';
            break;
          case 'empty-inventory':
            record['inventory'] = <String, Object>{
              'expected': <String>[],
              'present': <Object>[],
              'missing': <String>[],
              'unexpected': <String>[],
            };
            break;
          case 'empty-versions':
            record['versions'] = <String, Object>{};
            break;
          case 'null-attestation':
            record['attestation'] = null;
            break;
          case 'arbitrary-attestation':
            record['attestation'] = <String, Object>{'subject': 'fixture'};
            break;
          case 'incomplete-apple-attestation':
            record['attestation'] = <String, Object>{
              'emitted_payload_sha256': _abcSha256,
            };
            break;
          case 'attestation-digest-mismatch':
            (record['attestation']
                    as Map<String, dynamic>)['emitted_payload_sha256'] =
                List<String>.filled(64, 'f').join();
            break;
        }
        selected.writeAsStringSync(jsonEncode(record));
      }

      final payloadForValidation =
          corruption == 'empty-inventory' ||
                  corruption == 'empty-versions' ||
                  corruption == 'null-attestation' ||
                  corruption == 'arbitrary-attestation' ||
                  corruption == 'incomplete-apple-attestation'
              ? null
              : payload;
      final result = await _validate(
        fixture,
        proofs,
        payloadRoot: payloadForValidation,
      );
      expect(result.exitCode, isNot(0));
      expect(result.stderr, contains('Platform proof rejected:'));
      expect(result.stderr, isNot(contains(fixture.root.absolute.path)));
    });
  }

  test(
    'create reports missing, unexpected, mismatch, and unavailable families',
    () async {
      final root = Directory(p.join(fixture.root.path, 'create-payload'))
        ..createSync();
      File(p.join(root.path, 'libgit2.so')).writeAsStringSync('not-a-library');
      File(p.join(root.path, 'libssh2.so')).writeAsStringSync('not-a-library');
      File(p.join(root.path, 'unexpected.so')).writeAsStringSync('unexpected');
      final evidence = fixture.file('VERSION.dat')
        ..writeAsStringSync('libgit2: 0.0.1\nlibssh2: 0.0.2\nopenssl: 0.0.3\n');
      final output = Directory(p.join(fixture.root.path, 'created-proof'));

      final result = await _create(
        fixture,
        root: root,
        output: output,
        versionEvidence: evidence,
      );
      expect(result.exitCode, isNot(0));
      final record =
          jsonDecode(File(p.join(output.path, 'proof.json')).readAsStringSync())
              as Map<String, dynamic>;
      expect(record['status'], 'failed');
      expect(
        record['failure_codes'],
        containsAll(<String>[
          'unexpected-payload',
          'version-mismatch',
          'loader-failed',
        ]),
      );
      expect(record.toString(), isNot(contains(fixture.root.absolute.path)));

      File(p.join(root.path, 'libssh2.so')).deleteSync();
      final incompleteOutput = Directory(
        p.join(fixture.root.path, 'incomplete-proof'),
      );
      final incomplete = await _create(
        fixture,
        root: root,
        output: incompleteOutput,
        versionEvidence: evidence,
      );
      expect(incomplete.exitCode, isNot(0));
      final incompleteRecord =
          jsonDecode(
                File(
                  p.join(incompleteOutput.path, 'proof.json'),
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      expect(incompleteRecord['failure_codes'], contains('missing-payload'));

      final unavailable = await _create(
        fixture,
        root: Directory(p.join(fixture.root.path, 'absent')),
        output: Directory(p.join(fixture.root.path, 'absent-proof')),
      );
      expect(unavailable.exitCode, isNot(0));
      expect(unavailable.stderr, contains('unavailable'));

      final unsafeAbi = await _create(
        fixture,
        root: root,
        output: Directory(p.join(fixture.root.path, 'unsafe-proof')),
        abi: '..',
      );
      expect(unsafeAbi.exitCode, isNot(0));
      expect(unsafeAbi.stderr, contains('invalid-path'));
    },
  );

  test('producer proof with silent successful linkage round-trips', () async {
    final route = _hostLoadableRoute();
    if (route == null) return;
    final (platform, source) = route;
    final root = Directory(
      p.joinAll(<String>[
        payload.path,
        ..._payloadSegments(platform, 'default'),
      ]),
    );
    if (root.existsSync()) root.deleteSync(recursive: true);
    root.createSync(recursive: true);
    for (final template in _expectedInventory[platform]!) {
      final target = File(
        p.joinAll(<String>[
          root.path,
          ...p.split(template.replaceAll('*', '-3')),
        ]),
      )..parent.createSync(recursive: true);
      source.copySync(target.path);
    }
    final versions = fixture.file('round-trip-versions.txt')
      ..writeAsStringSync('1.9.7\n1.11.1\n3.0.15\n');
    final result = await _create(
      fixture,
      platform: platform,
      root: root,
      output: Directory(p.join(proofs.path, '$platform-default')),
      versionEvidence: versions,
      attestationInput: platform == 'macos' ? root : null,
    );
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    final aggregate = await _validate(fixture, proofs, payloadRoot: payload);
    expect(
      aggregate.exitCode,
      0,
      reason: '${aggregate.stdout}\n${aggregate.stderr}',
    );
  });
}

Future<void> _writeCompleteProofs(
  BehaviorProofFixture fixture,
  Directory root,
  Directory payloadRoot,
) async {
  for (final (platform, abi) in _scopes) {
    final payloadDirectory = Directory(
      p.joinAll(<String>[payloadRoot.path, ..._payloadSegments(platform, abi)]),
    )..createSync(recursive: true);
    final expected = _expectedInventory[platform]!;
    final present = <Object>[];
    for (final expectedPath in expected) {
      final actualPath = expectedPath.replaceAll('*', '-3');
      File(p.joinAll(<String>[payloadDirectory.path, ...p.split(actualPath)]))
        ..parent.createSync(recursive: true)
        ..writeAsStringSync('abc');
      present.add(<String, Object>{
        'path': actualPath,
        'sha256': _abcSha256,
        'size': 3,
      });
    }
    final versions = _fixtureVersions();
    final emittedPayloadSha256 = await _inventorySha256(
      fixture,
      payloadDirectory,
      present.cast<Map<String, Object>>(),
    );
    final attestation = <String, Object>{
      'emitted_payload_sha256': emittedPayloadSha256,
    };
    if (platform == 'macos' || platform == 'ios') {
      attestation.addAll(<String, Object>{
        'input_sha256': _abcSha256,
        'emitted_sha256': emittedPayloadSha256,
        'toolchain': 'fixture',
        'sdk': 'fixture',
        'compiled_metadata': versions,
      });
    }
    final directory = Directory(p.join(root.path, '$platform-$abi'))
      ..createSync();
    File(p.join(directory.path, 'proof.json')).writeAsStringSync(
      jsonEncode(<String, Object?>{
        'schema': 'platform-release-proof/v1',
        'candidate': 'fixture',
        'platform': platform,
        'abi': abi,
        'status': 'passed',
        'inventory': <String, Object>{
          'expected': expected,
          'present': present,
          'missing': <String>[],
          'unexpected': <String>[],
        },
        'linkage': <String, Object>{
          'result': 'passed',
          'diagnostic': 'fixture',
        },
        'versions': versions,
        'attestation': attestation,
        'failure_codes': <String>[],
      }),
    );
  }
}

Map<String, Object> _fixtureVersions() => <String, Object>{
  for (final version
      in <String, String>{
        'libgit2': '1.9.7',
        'libssh2': '1.11.1',
        'openssl': '3.0.15',
      }.entries)
    version.key: <String, Object>{
      'intended': version.value,
      'observed': version.value,
      'comparison': 'match',
      'evidence': 'fixture',
    },
};

Future<String> _inventorySha256(
  BehaviorProofFixture fixture,
  Directory root,
  List<Map<String, Object>> present,
) async {
  final result = await fixture.runBounded(_pythonExecutable(), <String>[
    '-c',
    "import hashlib,pathlib,sys;root=pathlib.Path(sys.argv[1]);d=hashlib.sha256();paths=sorted(sys.argv[2:]);[(d.update(path.encode()),d.update(hashlib.sha256((root/path).read_bytes()).hexdigest().encode())) for path in paths];print(d.hexdigest())",
    root.path,
    ...present.map((item) => item['path']! as String),
  ]);
  if (result.exitCode != 0) throw StateError(result.stderr as String);
  return (result.stdout as String).trim();
}

(String, File)? _hostLoadableRoute() {
  final candidates = switch (Platform.operatingSystem) {
    'windows' => <(String, String)>[
      (
        'windows',
        p.join(
          Platform.environment['SystemRoot'] ?? r'C:\Windows',
          'System32',
          'kernel32.dll',
        ),
      ),
    ],
    'linux' => <(String, String)>[
      ('linux', '/lib/x86_64-linux-gnu/libc.so.6'),
      ('linux', '/lib64/libc.so.6'),
    ],
    'macos' => <(String, String)>[('macos', '/usr/lib/libSystem.B.dylib')],
    _ => const <(String, String)>[],
  };
  for (final candidate in candidates) {
    final file = File(candidate.$2);
    if (file.existsSync()) return (candidate.$1, file);
  }
  return null;
}

List<String> _payloadSegments(String platform, String abi) =>
    switch (platform) {
      'linux' => <String>['linux'],
      'macos' => <String>['macos'],
      'windows' => <String>['windows'],
      'ios' => <String>['ios'],
      'android' => <String>['android', 'src', 'main', 'jniLibs', abi],
      _ => throw ArgumentError.value(platform, 'platform'),
    };

Future<ProcessResult> _validate(
  BehaviorProofFixture fixture,
  Directory proofs, {
  Directory? payloadRoot,
}) => fixture.runBounded(_pythonExecutable(), <String>[
  File('.github/scripts/platform_release_proof.py').absolute.path,
  'validate',
  '--proofs',
  proofs.path,
  if (payloadRoot != null) ...<String>['--payload-root', payloadRoot.path],
]);

Future<ProcessResult> _create(
  BehaviorProofFixture fixture, {
  String platform = 'linux',
  required Directory root,
  required Directory output,
  File? versionEvidence,
  Directory? attestationInput,
  String? abi,
}) => fixture.runBounded(_pythonExecutable(), <String>[
  File('.github/scripts/platform_release_proof.py').absolute.path,
  'create',
  '--platform',
  platform,
  if (abi != null) ...<String>['--abi', abi],
  '--root',
  root.path,
  '--output',
  output.path,
  '--candidate',
  'fixture',
  '--libgit2',
  '1.9.7',
  '--libssh2',
  '1.11.1',
  '--openssl',
  '3.0.15',
  if (versionEvidence != null) ...<String>[
    '--version-evidence',
    versionEvidence.path,
  ],
  if (attestationInput != null) ...<String>[
    '--attestation-input',
    attestationInput.path,
  ],
]);

String _pythonExecutable() => Platform.isWindows ? 'python' : 'python3';
