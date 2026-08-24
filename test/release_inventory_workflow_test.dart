import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'release workflow validates the complete native inventory before publish',
    () {
      final workflow =
          File('.github/workflows/build_package.yml').readAsStringSync();

      expect(workflow, contains('name: Verify native release inventory'));
      expect(workflow, contains(r'android/src/main/jniLibs/$abi/$library'));
      expect(workflow, contains(r'ios/$framework.xcframework'));
      expect(workflow, contains('linux/libssh2.so'));
      expect(workflow, contains('windows/libssh2.dll'));
      expect(workflow, contains('lib/src/bindings.dart'));
      expect(workflow, contains('Qualify OpenSSL provenance before package eligibility'));
      expect(
        workflow,
        contains(
          'needs: [run_linux_tests, run_macos_tests, run_windows_tests, run_ios_tests, run_android_tests, build_libgit2_android_other]',
        ),
      );
      expect(workflow, contains('Qualify same-run platform proofs before release eligibility'));
      expect(workflow, contains('Check expanded package size'));
      expect(workflow, contains('Validate publish package'));
    },
  );
}
