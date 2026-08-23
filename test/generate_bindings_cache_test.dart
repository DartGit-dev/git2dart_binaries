import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('binding cache key fingerprints ffigen configuration and lockfile', () {
    final action =
        File('.github/actions/generate-bindings/action.yml').readAsStringSync();

    const contractInputs =
        "hashFiles('.github/actions/generate-bindings/action.yml', ";
    expect("'ffigen.yaml'".allMatches(action), hasLength(2));
    expect("'pubspec.lock'".allMatches(action), hasLength(2));
    expect(contractInputs.allMatches(action), hasLength(2));
  });
}
