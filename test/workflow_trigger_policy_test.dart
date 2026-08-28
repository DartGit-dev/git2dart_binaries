import 'dart:io';

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

  test('classifies the docs tag from the commit subject only', () {
    const docsCommit = 'docs: refresh API reference [docs]';
    const bodyTaggedCommit =
        'fix: keep native validation enabled\n\nMention [docs] in the body only.';
    expect(
      facts.validationReachable(
        event: 'push',
        ref: 'refs/heads/main',
        commitMessage: docsCommit,
      ),
      isFalse,
    );
    expect(
      facts.validationReachable(
        event: 'push',
        ref: 'refs/heads/main',
        commitMessage: bodyTaggedCommit,
      ),
      isTrue,
    );
    final acknowledgement = facts.jobs['docs_commit_acknowledgement']!;
    expect(
      acknowledgement.condition.evaluate(
        event: 'push',
        ref: 'refs/heads/main',
        commitMessage: docsCommit,
      ),
      isTrue,
    );
    expect(
      acknowledgement.condition.evaluate(
        event: 'push',
        ref: 'refs/heads/main',
        commitMessage: 'docs: refresh API reference',
      ),
      isFalse,
    );
    expect(
      acknowledgement.condition.evaluate(
        event: 'push',
        ref: 'refs/heads/main',
        commitMessage: bodyTaggedCommit,
      ),
      isFalse,
    );

    final classifier = facts.jobs['classify_commit']!;
    final classifierScript =
        classifier.step('Classify commit subject').run ?? '';
    expect(classifierScript, contains(r'split("\n")[0]'));
    expect(acknowledgement.needs, contains('classify_commit'));
    for (final job in facts.jobs.values.where(
      (job) => job.condition.kind == WorkflowConditionKind.nonDocsCommit,
    )) {
      expect(job.needs, contains('classify_commit'), reason: job.id);
    }

    final workflow =
        File('.github/workflows/build_package.yml').readAsStringSync();
    expect(
      workflow,
      isNot(contains('contains(github.event.head_commit.message')),
    );
  });

  test('cold boots the cached Android AVD before integration tests', () {
    final workflow =
        File('.github/workflows/build_package.yml').readAsStringSync();

    expect(
      workflow,
      contains(
        'emulator-options: -no-window -gpu swiftshader_indirect '
        '-delay-adb -no-snapshot-load -no-snapshot-save -noaudio '
        '-no-boot-anim -camera-back none',
      ),
    );
  });

  test('switches iOS simulators before one bounded retry', () {
    final workflow =
        File('.github/workflows/build_package.yml').readAsStringSync();

    expect(
      workflow,
      contains(r'xcrun simctl terminate "$device_id" "$bundle_id" || true'),
    );
    expect(workflow, contains(r'xcrun simctl shutdown "$device_id" || true'));
    expect(workflow, contains('xcrun simctl list devices available -j'));
    expect(workflow, contains('device["udid"] != current'));
    expect(workflow, contains(r'device_id="$retry_device_id"'));
    expect(workflow, contains(r'xcrun simctl boot "$device_id"'));
    expect(RegExp('run_ios_tests 300').allMatches(workflow), hasLength(2));
  });
}
