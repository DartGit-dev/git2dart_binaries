import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('declares cache object limit with a pointer-width value', () {
    final wrapper = File('lib/src/opts_bindings.dart').readAsStringSync();
    expect(wrapper, contains('ffi.VarArgs<(ffi.Int, ffi.Size)>'));
  });
}
