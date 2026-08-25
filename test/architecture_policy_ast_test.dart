import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../tool/architecture_policy_facts.dart' as policy;
import 'support/behavior_proof_fixture.dart';

void main() {
  test('direct exact-pinned analyzer resolution is mandatory', () async {
    final resolution = policy.verifyAnalyzerResolution();
    expect(resolution.version, policy.expectedAnalyzerVersion);

    final fixture = await BehaviorProofFixture.create('analyzer-resolution-');
    try {
      final missing = fixture.file('missing.json')..writeAsStringSync(
        jsonEncode(<String, Object>{'packages': <Object>[]}),
      );
      expect(
        () => policy.verifyAnalyzerResolution(packageConfigPath: missing.path),
        throwsStateError,
      );

      final fakeRoot = Directory(p.join(fixture.root.path, 'analyzer'))
        ..createSync();
      File(
        p.join(fakeRoot.path, 'pubspec.yaml'),
      ).writeAsStringSync('name: analyzer\nversion: 0.0.0\n');
      final mismatch = fixture.file('mismatch.json')..writeAsStringSync(
        jsonEncode(<String, Object>{
          'packages': <Object>[
            <String, Object>{
              'name': 'analyzer',
              'rootUri': fakeRoot.uri.toString(),
            },
          ],
        }),
      );
      expect(
        () => policy.verifyAnalyzerResolution(packageConfigPath: mismatch.path),
        throwsStateError,
      );
    } finally {
      await fixture.dispose();
    }
  });

  test('AST facts keep raw lifecycle ownership inside runtime', () {
    final facts = policy.collectArchitectureFacts();
    final transitions =
        facts
            .where((fact) => fact.kind == 'native-lifecycle-transition')
            .toList();
    expect(transitions, isNotEmpty);
    expect(transitions.every((fact) => fact.allowed), isTrue);
    expect(
      facts.where((fact) => fact.kind == 'prohibited-lifecycle-global'),
      isEmpty,
    );

    final runtimeClasses =
        facts
            .where((fact) => fact.kind == 'class')
            .map((fact) => fact.symbol)
            .toSet();
    expect(
      runtimeClasses,
      containsAll(<String>[
        'Libgit2Runtime',
        'Libgit2RuntimeState',
        'Libgit2OwnerLease',
      ]),
    );
  });
}
