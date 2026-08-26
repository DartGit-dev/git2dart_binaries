import 'dart:io';

import 'package:test/test.dart';

import '../tool/workflow_policy_facts.dart';
import 'support/behavior_proof_fixture.dart';

void main() {
  final facts = WorkflowPolicyFacts.fromFile(
    '.github/workflows/build_package.yml',
  );

  test('validation is broad but publication is exact-main-push only', () {
    for (final scenario in <(String, String)>[
      ('pull_request', 'refs/heads/main'),
      ('push', 'refs/heads/feature'),
      ('push', 'refs/heads/main'),
    ]) {
      expect(
        facts.validationReachable(event: scenario.$1, ref: scenario.$2),
        isTrue,
      );
    }
    expect(
      facts.publicationReachable(event: 'pull_request', ref: 'refs/heads/main'),
      isFalse,
    );
    expect(
      facts.publicationReachable(event: 'push', ref: 'refs/heads/feature'),
      isFalse,
    );
    expect(
      facts.publicationReachable(event: 'push', ref: 'refs/heads/main'),
      isTrue,
    );
  });

  test('release qualification facts precede validation and publication', () {
    final publish = facts.jobs['publish_package']!;
    final validation = publish.stepIndex('Validate publish package');
    final publication = publish.stepIndex('Publish package');
    for (final prerequisite in <String>[
      'Download same-run platform proofs',
      'Qualify same-run platform proofs before release eligibility',
      'Verify native release inventory',
      'Qualify OpenSSL provenance before package eligibility',
      'Check expanded package size',
      'Assemble disposable same-run consumer bundle',
      'Compile public API from disposable consumer bundle',
      'Load native payload from disposable consumer bundle',
    ]) {
      final index = publish.stepIndex(prerequisite);
      expect(index, isNonNegative, reason: prerequisite);
      expect(index, lessThan(validation), reason: prerequisite);
      expect(index, lessThan(publication), reason: prerequisite);
    }
    expect(
      publish.needs,
      containsAll(<String>[
        'run_linux_tests',
        'run_macos_tests',
        'run_windows_tests',
        'run_ios_tests',
        'run_android_tests',
        'build_libgit2_android_other',
      ]),
    );
  });

  test('unsupported workflow conditions fail closed', () {
    expect(
      () => WorkflowCondition.parse('github.ref != null'),
      throwsFormatException,
    );
  });

  test('workflow tool exits successfully on the checked-in graph', () async {
    final result = await Process.run(dartExecutable(), <String>[
      File('tool/workflow_policy_facts.dart').absolute.path,
    ]);
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
  });
}
