import 'dart:convert';
import 'dart:io';

import 'package:git2dart_binaries/src/runtime.dart';

void main(List<String> arguments) {
  final mode = arguments.single;
  if (mode == 'android-plan') {
    final plan = nativeLoaderPlanForTesting('android');
    stdout.writeln(
      jsonEncode(<String, Object>{
        'library': plan.libraryName,
        'package_fallback': plan.hasPackageFallback,
      }),
    );
    return;
  }
  if (mode != 'load') throw ArgumentError.value(mode, 'mode');
  libgit2Runtime.ensureInitialized();
  stdout.writeln(
    jsonEncode(<String, Object>{
      'status': 'loaded',
      'package_root':
          Platform.environment['GIT2DART_BINARIES_PACKAGE_ROOT'] ?? '',
    }),
  );
  libgit2Runtime.shutdown();
}
