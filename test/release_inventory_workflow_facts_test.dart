import 'package:test/test.dart';

import '../tool/workflow_policy_facts.dart';

void main() {
  test('native inventory and proof qualification precede publication', () {
    final facts = WorkflowPolicyFacts.fromFile(
      '.github/workflows/build_package.yml',
    );
    final publish = facts.jobs['publish_package']!;
    final release = publish.stepIndex('Publish package');
    for (final name in <String>[
      'Qualify same-run platform proofs before release eligibility',
      'Verify native release inventory',
      'Qualify OpenSSL provenance before package eligibility',
      'Check expanded package size',
      'Validate publish package',
    ]) {
      final index = publish.stepIndex(name);
      expect(index, isNonNegative, reason: name);
      expect(index, lessThan(release), reason: name);
    }
    expect(publish.needs.length, 6);
  });
}
