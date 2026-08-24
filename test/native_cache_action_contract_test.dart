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
      final android =
          File('.github/actions/build-android/action.yml').readAsStringSync();
      final linux =
          File('.github/actions/build-linux/action.yml').readAsStringSync();
      final macos =
          File('.github/actions/build-macos/action.yml').readAsStringSync();
      final workflow =
          File('.github/workflows/build_package.yml').readAsStringSync();

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
      expect(windows, contains('.native-cache/windows'));
      expect(windows, contains('Stage Windows native cache'));
      expect(windows, contains('Verify cached Windows libraries load'));
      expect(
        windows,
        contains('VC-WIN64A shared no-tests'),
        reason: 'Windows CI must skip the redundant upstream OpenSSL test suite',
      );
      expect(windows, isNot(contains('nmake test')));
      expect(
        windows,
        contains(r'Copy-Item -LiteralPath $source -Destination $destination'),
        reason: 'a valid workspace cache must be staged before validation',
      );
      expect(
        windows,
        contains(r'$global:LASTEXITCODE = 0'),
        reason: 'an invalid Windows cache must fall through to a source build',
      );

      String artifactUpload(String source, String name) {
        final match = RegExp(
          'name: ${RegExp.escape(name)}\\r?\\n',
        ).firstMatch(source);
        expect(match, isNotNull, reason: 'missing $name upload');
        final start = match!.start;
        final end = source.indexOf('retention-days: 1', start);
        expect(end, isNonNegative, reason: 'missing $name retention');
        return source.substring(start, end);
      }

      for (final entry in <(String, String)>[
        (android, r'cache-android-${{ inputs.architecture }}'),
        (linux, 'cache-linux'),
        (macos, 'cache-macos'),
        (windows, 'cache-windows'),
      ]) {
        expect(
          artifactUpload(entry.$1, entry.$2),
          isNot(contains('provenance')),
          reason: '${entry.$2} must deliver native export contents directly',
        );
      }
      expect(
        workflow,
        contains(r'$output_dir/provenance/openssl-provenance.json'),
        reason: 'cache-ios must create its OpenSSL provenance sidecar inside the uploaded export tree',
      );
    },
  );
}
