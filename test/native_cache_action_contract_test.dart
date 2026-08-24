import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'native cache actions preserve manifest provenance and workspace paths',
    () {
      final bindings =
          File(
            '.github/actions/generate-bindings/action.yml',
          ).readAsStringSync();
      final ios =
          File('.github/actions/build-ios/action.yml').readAsStringSync();
      final windows =
          File('.github/actions/build-windows/action.yml').readAsStringSync();

      expect(bindings, contains('--provenance source-build'));
      expect(
        bindings,
        contains(r'--source-ref "refs/tags/v${{ inputs.libgit2_version }}"'),
      );
      expect(
        ios,
        contains(
          r'cp "$cache_root/manifest.json" "$cache_root/export/provenance-',
        ),
      );
      expect(ios, isNot(contains(r'cp "$BUILD_ROOT/manifest.json"')));

      final restoreStep =
          windows.split('    - name: Validate Windows native cache').first;
      final saveStep =
          windows
              .substring(
                windows.indexOf('    - name: Save Windows native cache'),
              )
              .split('    - name: Cache git2 library')
              .first;
      expect(restoreStep, isNot(contains('D:/export')));
      expect(saveStep, isNot(contains('D:/export')));
    },
  );
}
