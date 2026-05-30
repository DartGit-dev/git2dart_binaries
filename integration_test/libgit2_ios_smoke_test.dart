import 'dart:ffi' as ffi;

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

typedef _GitLibgit2InitNative = ffi.Int Function();
typedef _GitLibgit2InitDart = int Function();

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('libgit2 initializes from process symbols', (_) async {
    // Keep these prints explicit so CI logs show exactly where an iOS launch
    // hang happens before the full FFI test suite is loaded.
    print('git2dart ios smoke: opening process library');
    final library = ffi.DynamicLibrary.process();

    print('git2dart ios smoke: looking up git_libgit2_init');
    final init = library.lookupFunction<_GitLibgit2InitNative, _GitLibgit2InitDart>(
      'git_libgit2_init',
    );

    print('git2dart ios smoke: looking up git_libgit2_shutdown');
    final shutdown =
        library.lookupFunction<_GitLibgit2InitNative, _GitLibgit2InitDart>(
      'git_libgit2_shutdown',
    );

    print('git2dart ios smoke: calling git_libgit2_init');
    final initResult = init();
    print('git2dart ios smoke: git_libgit2_init returned $initResult');

    expect(initResult, greaterThan(0));

    final shutdownResult = shutdown();
    print('git2dart ios smoke: git_libgit2_shutdown returned $shutdownResult');
  });
}
