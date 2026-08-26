import 'package:test/test.dart';

import '../tool/workflow_policy_facts.dart';

void main() {
  final facts = WorkflowPolicyFacts.fromFile(
    '.github/workflows/build_package.yml',
  );

  test(
    'validates pushes from every branch while retaining main pull requests',
    () {
      expect(
        facts.eventAccepted(event: 'push', ref: 'refs/heads/feature'),
        isTrue,
      );
      expect(
        facts.eventAccepted(event: 'pull_request', ref: 'refs/heads/main'),
        isTrue,
      );
      expect(
        facts.eventAccepted(event: 'pull_request', ref: 'refs/heads/feature'),
        isFalse,
      );
    },
  );

  test(
    'keeps package validation available while guarding only publication',
    () {
      expect(
        facts.validationReachable(
          event: 'pull_request',
          ref: 'refs/heads/main',
        ),
        isTrue,
      );
      expect(
        facts.publicationReachable(
          event: 'pull_request',
          ref: 'refs/heads/main',
        ),
        isFalse,
      );
      expect(
        facts.publicationReachable(event: 'push', ref: 'refs/heads/main'),
        isTrue,
      );
    },
  );
}
