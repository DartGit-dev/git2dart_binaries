import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('mobile cache fingerprints include output-affecting target inputs', () {
    final android =
        File('.github/actions/build-android/action.yml').readAsStringSync();
    final ios = File('.github/actions/build-ios/action.yml').readAsStringSync();

    expect(android, contains(r'-android-api-${{ inputs.android_api_level }}'));
    expect(ios, contains(r'-deployment-${{ inputs.ios_deployment_target }}'));
    expect(ios, contains(r'-openssl-target-${{ inputs.openssl_target }}'));
  });
}
