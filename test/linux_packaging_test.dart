import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  test('bundles libgit2 and libssh2 for Linux Flutter consumers', () {
    final cmake = File(p.join('linux', 'CMakeLists.txt')).readAsStringSync();

    expect(cmake, contains(r'"${CMAKE_CURRENT_SOURCE_DIR}/libgit2.so"'));
    expect(cmake, contains(r'"${CMAKE_CURRENT_SOURCE_DIR}/libssh2.so"'));
  });
}
