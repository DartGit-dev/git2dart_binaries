import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'workflow emits independently named same-run platform proofs before eligibility',
    () {
      final workflow =
          File('.github/workflows/build_package.yml').readAsStringSync();
      for (final proof in <String>[
        'platform-proof-linux',
        'platform-proof-macos',
        'platform-proof-windows',
        'platform-proof-ios',
        'platform-proof-android-x86_64',
        r'platform-proof-android-${{ matrix.os }}',
      ]) {
        expect(workflow, contains(proof));
      }
      expect(workflow, contains('Download same-run platform proofs'));
      expect(
        workflow,
        contains('Qualify same-run platform proofs before release eligibility'),
      );
      expect(
        workflow.indexOf(
          'Qualify same-run platform proofs before release eligibility',
        ),
        lessThan(workflow.indexOf('Check expanded package size')),
      );
      expect(
        workflow.indexOf(
          'Qualify same-run platform proofs before release eligibility',
        ),
        lessThan(workflow.indexOf('dart pub publish --dry-run')),
      );
    },
  );

  test(
    'proof artifacts retain the established seven-day release-package policy',
    () {
      final workflow =
          File('.github/workflows/build_package.yml').readAsStringSync();
      expect(
        RegExp(
          r'name: platform-proof-[\s\S]{0,180}retention-days: 7',
        ).allMatches(workflow).length,
        greaterThanOrEqualTo(6),
      );
      expect(workflow, contains('name: release-package'));
      expect(workflow, contains('retention-days: 7'));
    },
  );

  test(
    'platform-proof delta excludes OpenSSL parity and Git history gates',
    () {
      final workflow =
          File('.github/workflows/build_package.yml').readAsStringSync();
      final proofSection = workflow.substring(
        workflow.indexOf('Download same-run platform proofs'),
        workflow.indexOf('Verify native release inventory'),
      );
      expect(proofSection, isNot(contains('approved-exception')));
      expect(proofSection, isNot(contains('git log')));
    },
  );
}
