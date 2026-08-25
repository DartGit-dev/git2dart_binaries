import 'package:test/test.dart';

import '../tool/workflow_policy_facts.dart';

void main() {
  test(
    'binding cache facts fingerprint generator configuration and lockfile',
    () {
      final action = parseYamlFile(
        '.github/actions/generate-bindings/action.yml',
      );
      final runs = action['runs']! as Map<String, Object?>;
      final steps = runs['steps']! as List<Object?>;
      final keys = <Object?>[];
      for (final raw in steps) {
        final step = raw! as Map<String, Object?>;
        final uses = step['uses']?.toString() ?? '';
        if (!uses.startsWith('actions/cache/')) continue;
        final withValues = step['with']! as Map<String, Object?>;
        keys.add(withValues['key']);
      }
      expect(keys, hasLength(2));
      for (final key in keys) {
        expect(
          githubHashFileInputs(key),
          containsAll(<String>{
            '.github/actions/generate-bindings/action.yml',
            '.github/scripts/native_cache_manifest.py',
            'ffigen.yaml',
            'pubspec.lock',
          }),
        );
      }
    },
  );
}
