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
    },
  );
}
