import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:git2dart_binaries/git2dart_binaries.dart';
import 'package:path/path.dart' as p;

final _library = _loadLibrary();
final libgit2Opts = Libgit2Opts(_library);
final libgit2 = _initializeLibgit2(_library);

String? _cachedPackageRoot;

({String name, String? subDir}) _platformTarget() {
  if (Platform.isWindows) {
    return (name: 'libgit2.dll', subDir: 'windows');
  } else if (Platform.isMacOS) {
    return (name: 'libgit2.dylib', subDir: 'macos');
  } else if (Platform.isLinux) {
    return (name: 'libgit2.so', subDir: 'linux');
  } else if (Platform.isAndroid) {
    return (name: 'libgit2.so', subDir: null);
  }
  throw UnsupportedError('Not supported platform');
}

DynamicLibrary _loadLibrary() {
  final target = _platformTarget();

  try {
    return DynamicLibrary.open(target.name);
  } catch (firstError) {
    if (target.subDir == null) {
      stderr.writeln(
        'Failed to open libgit2: ${target.name} -> $firstError\n'
        'Make sure the library is available on the system search path.',
      );
      rethrow;
    }

    final packageRoot = _packageRoot();
    _loadPlatformDependencies(packageRoot);
    final fallbackPath = p.join(packageRoot, target.subDir!, target.name);
    try {
      return DynamicLibrary.open(fallbackPath);
    } catch (secondError) {
      stderr.writeln(
        'Failed to open libgit2. Tried:\n'
        '  ${target.name} -> $firstError\n'
        '  $fallbackPath -> $secondError\n'
        'Make sure the library is bundled with the application.',
      );
      rethrow;
    }
  }
}

String _packageRoot() => _cachedPackageRoot ??= _resolvePackageRoot();

Libgit2 _initializeLibgit2(DynamicLibrary library) {
  final instance = Libgit2(library);
  instance.git_libgit2_init();
  return instance;
}

void _loadPlatformDependencies(String packageRoot) {
  try {
    if (Platform.isLinux) {
      DynamicLibrary.open(p.join(packageRoot, 'linux', 'libssh2.so'));
    } else if (Platform.isMacOS) {
      DynamicLibrary.open(p.join(packageRoot, 'macos', 'libssh2.1.dylib'));
    } else if (Platform.isWindows) {
      DynamicLibrary.open(p.join(packageRoot, 'windows', 'libssh2.dll'));
    }
  } catch (e) {
    stderr.writeln(
      'Failed to load libgit2 dependency: $e\n'
      'Make sure dependent libraries are bundled with the application.',
    );
    rethrow;
  }
}

String _resolvePackageRoot() {
  final packageUri = _tryResolvePackageUri();
  if (packageUri != null) {
    return File.fromUri(packageUri).parent.parent.absolute.path;
  }

  final configRoot = _packageRootFromConfig();
  if (configRoot != null) {
    return configRoot;
  }

  throw StateError('Unable to resolve git2dart_binaries package location.');
}

Uri? _tryResolvePackageUri() {
  try {
    return Isolate.resolvePackageUriSync(
      Uri.parse('package:git2dart_binaries/git2dart_binaries.dart'),
    );
  } on UnsupportedError {
    return null;
  }
}

String? _packageRootFromConfig() {
  final configUri = _packageConfigUri();
  if (configUri == null) {
    return null;
  }

  try {
    final file = File.fromUri(configUri);
    if (!file.existsSync()) return null;

    final content = file.readAsStringSync();
    final decoded = jsonDecode(content);
    if (decoded is! Map<String, dynamic>) return null;
    final packages = decoded['packages'];
    if (packages is! List) return null;

    for (final entry in packages) {
      if (entry is! Map<String, dynamic>) continue;
      if (entry['name'] != 'git2dart_binaries') continue;
      final rootUri = entry['rootUri'];
      if (rootUri is! String) continue;

      final resolved = configUri.resolveUri(Uri.parse(rootUri));
      return File.fromUri(resolved).absolute.path;
    }
  } catch (_) {
    return null;
  }

  return null;
}

Uri? _packageConfigUri() {
  try {
    final uri = Isolate.packageConfigSync;
    if (uri != null) return uri;
  } catch (_) {
    // ignored
  }

  final envPath = Platform.environment['DART_PACKAGE_CONFIG'];
  if (envPath != null && envPath.isNotEmpty) {
    return File(envPath).absolute.uri;
  }

  for (final arg in Platform.executableArguments) {
    if (arg.startsWith('--packages=')) {
      final path = arg.substring('--packages='.length);
      return File(path).absolute.uri;
    }
  }
  return null;
}
