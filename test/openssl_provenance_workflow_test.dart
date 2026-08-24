import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('native manifests fail closed on mutually exclusive provenance', () {
    final script = File('.github/scripts/native_cache_manifest.py')
        .readAsStringSync();
    expect(script, contains('SCHEMA = "native-v2"'));
    expect(script, contains('source-build requires --source-ref'));
    expect(script, contains('approved-exception requires --exception-id'));
    expect(script, contains('Manifest fields are missing, contradictory, or unknown'));
  });

  test('release workflow requires source provenance or checked-in exact parity', () {
    final workflow = File('.github/workflows/build_package.yml').readAsStringSync();
    expect(workflow, contains('Qualify OpenSSL provenance before package eligibility'));
    expect(workflow, contains("{'windows', 'linux', 'macos', 'android', 'ios'}"));
    expect(workflow, contains("'approved-exception'"));
    expect(workflow, contains('Exception parity is not exact'));
  });

  test('exception format is checked in and requires reviewable parity evidence', () {
    final readme = File('.github/openssl-exceptions/README.md').readAsStringSync();
    expect(readme, contains('exact_parity'));
    expect(readme, contains('review_by'));
    expect(readme, contains('fail closed'));
  });
}
