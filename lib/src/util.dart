import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

DynamicLibrary _loadLibrary() {
  try {
    if (Platform.isWindows) {
      return DynamicLibrary.open('libgit2.dll');
    } else if (Platform.isLinux || Platform.isAndroid) {
      return DynamicLibrary.open('libgit2.so');
    } else if (Platform.isMacOS) {
      return DynamicLibrary.open('libgit2.dylib');
    }
    throw "Not supported platform";
  } catch (e) {
    stderr.writeln(
      'Failed to open the library. Make sure that libgit2 library is bundled '
      'with the application.',
    );
    rethrow;
  }
}

Libgit2 _initLibrary(DynamicLibrary library) {
  final libgit2 = Libgit2(library);

  libgit2.git_libgit2_init();

  if (Platform.isAndroid) {
    unawaited(_configureAndroidSSL());
  }

  return libgit2;
}

Future<void> _configureAndroidSSL() async {
  try {
    final certPath = await AndroidSSLHelper.initialize();
    using((arena) {
      final certPathC = certPath.toNativeUtf8(allocator: arena);
      libgit2Opts.git_libgit2_opts_set_ssl_cert_locations(
        certPathC.cast<Char>(),
        nullptr,
      );
    });
  } catch (error, stackTrace) {
    stderr.writeln(
      'Failed to configure Android SSL certificates: $error\n$stackTrace',
    );
  }
}

final _library = _loadLibrary();
final libgit2Opts = Libgit2Opts(_library);

final Libgit2 libgit2 = _initLibrary(_library);
