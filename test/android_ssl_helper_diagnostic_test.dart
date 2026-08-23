import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('temporary directory resolution shares the TLS diagnostic boundary', () {
    final source = File(
      'lib/src/android_ssl_helper.dart',
    ).readAsStringSync().replaceAll('\r\n', '\n');

    expect(source, contains("try {\n      // Get the app's cache directory"));
    expect(source, contains('final cacheDir = await getTemporaryDirectory();'));
    expect(
      source,
      contains("stderr.write('Android cert initialization failed.');"),
    );
    expect(
      source.indexOf('try {'),
      lessThan(source.indexOf('getTemporaryDirectory()')),
    );
  });
}
