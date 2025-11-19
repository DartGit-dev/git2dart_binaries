import 'dart:ffi';
import 'dart:io';

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

final _library = _loadLibrary();
final libgit2Opts = Libgit2Opts(_library);

final libgit2 = Libgit2(_library);
