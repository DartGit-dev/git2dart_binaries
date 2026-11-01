import 'dart:io';

import 'package:git2dart_binaries/git2dart_binaries.dart';

void main() {
  try {
    final features = libgit2Runtime.withCall(
      (bindings) => bindings.git_libgit2_features(),
    );
    if (features < 0) throw StateError('libgit2 feature query failed');

    final expected = File(
      Platform.environment['GIT2DART_EXPECTED_SSH2']!,
    ).resolveSymbolicLinksSync();
    final mappings = File('/proc/self/maps').readAsStringSync();
    if (!mappings.contains(expected)) {
      throw StateError('The relocated bundle did not load its own libssh2.so.1');
    }

    libgit2Runtime.shutdown();
    stdout.writeln('Loaded libgit2 and its packaged libssh2.so.1');
    exit(0);
  } catch (error, stack) {
    stderr.writeln('$error\n$stack');
    exit(1);
  }
}
