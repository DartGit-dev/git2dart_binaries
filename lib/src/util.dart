import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:git2dart_binaries/src/bindings.dart';
import 'package:git2dart_binaries/src/opts_bindings.dart';
import 'package:path/path.dart' as path;
import 'package:pub_semver/pub_semver.dart';

String _getLibName() {
  var ext = 'so';

  if (Platform.isWindows) {
    ext = 'dll';
  } else if (Platform.isMacOS) {
    ext = 'dylib';
  } else if (!Platform.isLinux) {
    throw Exception('Unsupported platform.');
  }

  return 'libgit2.$ext';
}

/// Returns location of the most recent verison of the git2dart package
/// contained in the cache.
String? _checkCache() {
  final cache =
      json.decode(
            Process.runSync('flutter', [
                  'pub',
                  'cache',
                  'list',
                ], runInShell: true).stdout
                as String,
          )
          as Map<String, dynamic>;
  final packages = cache['packages'] as Map<String, dynamic>;
  final libPackages = packages['git2dart_binaries'] as Map<String, dynamic>?;
  final versions = libPackages?.keys.map((e) => Version.parse(e)).toList();
  final latestVersion =
      libPackages?[Version.primary(versions!).toString()]
          as Map<String, dynamic>?;
  return latestVersion?['location'] as String?;
}

/// Checks if [File]/[Link] exists for [path].
bool _doesFileExist(String path) {
  return File(path).existsSync() || Link(path).existsSync();
}

/// Returns path to dynamic library if found.
String? _resolveLibPath(String name) {
  // If lib is in executable's folder.
  var libPath = path.join(path.dirname(Platform.resolvedExecutable), name);
  if (_doesFileExist(libPath)) return libPath;

  // If lib is in executable's bundled 'lib' folder.
  libPath = path.join(path.dirname(Platform.resolvedExecutable), 'lib', name);
  if (_doesFileExist(libPath)) return libPath;

  // If lib is installed in system dir.
  if (Platform.isMacOS || Platform.isLinux) {
    final paths = [
      '/usr/local/lib/libgit2.dylib',
      '/usr/local/lib/libgit2.so',
      '/usr/lib64/libgit2.so',
    ];
    for (final path in paths) {
      if (_doesFileExist(path)) return path;
    }
  }

  // If lib is in '.pub_cache' folder.
  final cachedLocation = _checkCache();
  if (cachedLocation != null) {
    libPath = path.join(cachedLocation, Platform.operatingSystem, name);
    if (_doesFileExist(libPath)) return libPath;
  }

  return null;
}

DynamicLibrary _loadLibrary(String name) {
  try {
    final libraryPath = _resolveLibPath(name) ?? name;

    if (Platform.isLinux) {
      DynamicLibrary.open(path.join(path.dirname(libraryPath), "libssh2.so"));
    }

    if (Platform.isMacOS) {
      DynamicLibrary.open(
        path.join(path.dirname(libraryPath), "libssh2.1.dylib"),
      );
    }

    if (Platform.isWindows) {
      DynamicLibrary.open(path.join(path.dirname(libraryPath), "libssh2.dll"));
    }
    return DynamicLibrary.open(libraryPath);
  } catch (e) {
    stderr.writeln(
      'Failed to open the library. Make sure that libgit2 library is bundled '
      'with the application.',
    );
    rethrow;
  }
}

final _library = _loadLibrary(_getLibName());

final libgit2 = Libgit2(_library);
final libgit2Opts = Libgit2Opts(_library);
