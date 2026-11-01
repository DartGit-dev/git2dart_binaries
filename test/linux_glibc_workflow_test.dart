import 'package:test/test.dart';

import '../tool/workflow_policy_facts.dart';

void main() {
  test(
    'Linux artifacts are built and opened on the supported glibc baseline',
    () {
      final workflow = parseYamlFile('.github/workflows/build_package.yml');
      final jobs = workflow['jobs']! as Map<String, Object?>;
      final build = jobs['build_libgit2_linux']! as Map<String, Object?>;
      final compatibility =
          jobs['run_linux_compatibility']! as Map<String, Object?>;
      final publish = jobs['publish_package']! as Map<String, Object?>;

      expect(
        (build['container']! as Map<String, Object?>)['image'],
        'ubuntu:22.04',
      );
      expect(
        (compatibility['container']! as Map<String, Object?>)['image'],
        'ubuntu:22.04',
      );
      expect(compatibility['needs'], 'build_libgit2_linux');
      expect(publish['needs'], contains('run_linux_compatibility'));

      final steps =
          (compatibility['steps']! as List<Object?>)
              .cast<Map<String, Object?>>();
      final download = steps.singleWhere(
        (step) => step['name'] == 'Download Linux artifacts',
      );
      expect(
        (download['with']! as Map<String, Object?>)['name'],
        'cache-linux',
      );
      final smoke = steps.singleWhere(
        (step) => step['name'] == 'Open a repository on glibc 2.35',
      );
      expect(smoke.containsKey('if'), isFalse);
      expect(smoke['continue-on-error'], isNot(true));
      expect(smoke['run'], contains('git_repository_open'));
    },
  );

  test(
    'glibc validation runs before cache save and upload, including cache hits',
    () {
      final action = parseYamlFile('.github/actions/build-linux/action.yml');
      final runs = action['runs']! as Map<String, Object?>;
      final steps =
          (runs['steps']! as List<Object?>).cast<Map<String, Object?>>();
      final checkIndex = steps.indexWhere(
        (step) => step['name'] == 'Verify Linux glibc compatibility',
      );
      final saveIndex = steps.indexWhere(
        (step) => step['name'] == 'Save Linux native cache',
      );
      final uploadIndex = steps.indexWhere(
        (step) => step['name'] == 'Cache git2 library',
      );
      expect(checkIndex, isNonNegative);
      expect(checkIndex, lessThan(saveIndex));
      expect(checkIndex, lessThan(uploadIndex));
      final check = steps[checkIndex];
      expect(check.containsKey('if'), isFalse);
      expect(check['continue-on-error'], isNot(true));
      expect(check['run'], contains('/tmp/export/libgit2.so'));
      expect(check['run'], contains('/tmp/export/libssh2.so'));
    },
  );
}
