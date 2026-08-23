import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('desktop fallback preserves the original failure and failing stage', () {
    final source = File('lib/src/runtime.dart').readAsStringSync();

    expect(source, contains("var fallbackStage = 'package root resolution';"));
    expect(source, contains("fallbackStage = 'dependency preload';"));
    expect(source, contains('fallbackStage = fallbackPath;'));
    expect(source, contains(r'$firstError'));
    expect(source, contains(r'$fallbackStage -> $fallbackError'));
  });
}
