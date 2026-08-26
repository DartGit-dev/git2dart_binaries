import 'package:test/test.dart';

import '../tool/workflow_policy_facts.dart';

void main() {
  test('OpenSSL provenance qualification is a parsed release prerequisite', () {
    final facts = WorkflowPolicyFacts.fromFile(
      '.github/workflows/build_package.yml',
    );
    final publish = facts.jobs['publish_package']!;
    final provenance = publish.stepIndex(
      'Qualify OpenSSL provenance before package eligibility',
    );
    expect(provenance, isNonNegative);
    expect(provenance, lessThan(publish.stepIndex('Validate publish package')));
    expect(provenance, lessThan(publish.stepIndex('Publish package')));
  });
}
