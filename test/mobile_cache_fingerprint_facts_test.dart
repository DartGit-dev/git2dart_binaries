import 'package:test/test.dart';

import '../tool/workflow_policy_facts.dart';

void main() {
  test('mobile fingerprints include all output-affecting target inputs', () {
    Set<String> fingerprintInputs(String path, String stepName) {
      final action = parseYamlFile(path);
      final runs = action['runs']! as Map<String, Object?>;
      final steps = runs['steps']! as List<Object?>;
      final step = steps.cast<Map<String, Object?>>().singleWhere(
        (step) => step['name'] == stepName,
      );
      return githubInputReferences(step['run']);
    }

    expect(
      fingerprintInputs(
        '.github/actions/build-android/action.yml',
        'Fingerprint Android toolchain',
      ),
      contains('android_api_level'),
    );
    expect(
      fingerprintInputs(
        '.github/actions/build-ios/action.yml',
        'Fingerprint iOS toolchain',
      ),
      containsAll(<String>{'ios_deployment_target', 'openssl_target'}),
    );
  });
}
