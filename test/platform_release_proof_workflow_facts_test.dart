import 'package:test/test.dart';

import '../tool/workflow_policy_facts.dart';

void main() {
  final facts = WorkflowPolicyFacts.fromFile(
    '.github/workflows/build_package.yml',
  );

  test('same-run platform proof artifacts are upstream of eligibility', () {
    final publish = facts.jobs['publish_package']!;
    final download = publish.stepIndex('Download same-run platform proofs');
    final qualify = publish.stepIndex(
      'Qualify same-run platform proofs before release eligibility',
    );
    final validate = publish.stepIndex('Validate publish package');
    final release = publish.stepIndex('Publish package');
    expect(download, isNonNegative);
    expect(qualify, greaterThan(download));
    expect(qualify, lessThan(validate));
    expect(qualify, lessThan(release));
    expect(
      publish
          .step('Qualify same-run platform proofs before release eligibility')
          .run,
      contains('--payload-root .'),
    );

    final proofUploads =
        facts.jobs.values
            .expand((job) => job.steps)
            .where(
              (step) =>
                  step.uses?.startsWith('actions/upload-artifact@') ?? false,
            )
            .where(
              (step) => step.withValues['name'].toString().startsWith(
                'platform-proof-',
              ),
            )
            .toList();
    expect(proofUploads.length, greaterThanOrEqualTo(6));
    expect(
      proofUploads.every((step) => step.withValues['retention-days'] == 7),
      isTrue,
    );
  });
}
