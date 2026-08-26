import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'native error pointer construction stays internal to the error library',
    () {
      final source = File('lib/src/error.dart').readAsStringSync();

      expect(source, contains('LibGit2Error._(this._errorPointer);'));
      expect(
        source,
        contains('return error == nullptr ? null : LibGit2Error._(error);'),
      );
      expect(source, isNot(contains('LibGit2Error(this._errorPointer);')));
    },
  );
}
