import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:git2dart_binaries/src/bindings.dart';
import 'package:git2dart_binaries/src/error.dart';
import 'package:git2dart_binaries/src/opts_bindings.dart';
import 'package:path/path.dart' as p;

export 'error.dart' show Libgit2LifecycleException, Libgit2LifecycleOperation;

/// The isolate-local owner of this package's libgit2 lifecycle.
///
/// Each isolate gets its own lazily-created instance and contributes at most
/// one native `git_libgit2_init` increment to libgit2's process-global count.
final libgit2Runtime = Libgit2Runtime._load();

/// Public managed access to the loaded libgit2 runtime.
final class Libgit2Runtime {
  factory Libgit2Runtime._load() {
    final library = _loadLibrary();
    final bindings = Libgit2(library);
    final options = Libgit2Opts(library);
    final state = Libgit2RuntimeState._(
      initialize: () => bindings.git_libgit2_init(),
      shutdown: () => bindings.git_libgit2_shutdown(),
      onFinalizerError: _reportFinalizerError,
    );
    return Libgit2Runtime._(bindings, options, state);
  }

  Libgit2Runtime._(this._bindings, this._options, this._state);

  final Libgit2 _bindings;
  final Libgit2Opts _options;
  final Libgit2RuntimeState _state;

  /// Generated non-lifecycle bindings protected by the managed native lease.
  Libgit2 get bindings {
    _state.ensureInitialized();
    return _bindings;
  }

  /// Global-option bindings protected by the managed native lease.
  Libgit2Opts get options {
    _state.ensureInitialized();
    return _options;
  }

  bool get isInitialized => _state.isInitialized;
  bool get isTerminated => _state.isTerminated;
  int get activeCallCount => _state.activeCallCount;
  int get liveOwnerCount => _state.liveOwnerCount;

  /// Ensures that this isolate owns one checked native lease.
  void ensureInitialized() => _state.ensureInitialized();

  /// Runs one synchronous ownerless native operation under a transient pin.
  T withCall<T>(T Function(Libgit2 bindings) callback) =>
      _state.withCall(() => callback(_bindings));

  /// Acquires a persistent logical pin for an independently usable owner.
  Libgit2OwnerLease acquireOwner({String? debugLabel}) =>
      _state.acquireOwner(debugLabel: debugLabel);

  /// Releases this isolate's native lease once no protected work remains.
  int shutdown() => _state.shutdown();
}

/// Deterministic lifecycle state machine, exposed for package diagnostics/tests.
final class Libgit2RuntimeState {
  Libgit2RuntimeState._({
    required int Function() initialize,
    required int Function() shutdown,
    required void Function(Object, StackTrace) onFinalizerError,
  }) : _initializeNative = initialize,
       _shutdownNative = shutdown,
       _onFinalizerError = onFinalizerError;

  /// Creates a platform-independent state machine with injected native calls.
  factory Libgit2RuntimeState.forTesting({
    required int Function() initialize,
    required int Function() shutdown,
    void Function(Object, StackTrace)? onFinalizerError,
  }) => Libgit2RuntimeState._(
    initialize: initialize,
    shutdown: shutdown,
    onFinalizerError: onFinalizerError ?? _reportFinalizerError,
  );

  final int Function() _initializeNative;
  final int Function() _shutdownNative;
  final void Function(Object, StackTrace) _onFinalizerError;
  final Finalizer<_OwnerCleanup> _ownerFinalizer = Finalizer<_OwnerCleanup>(
    _finalizeOwner,
  );

  _RuntimePhase _phase = _RuntimePhase.uninitialized;
  int _activeCallCount = 0;
  int _liveOwnerCount = 0;
  late int _shutdownResult;

  bool get isInitialized => _phase == _RuntimePhase.initialized;
  bool get isTerminated =>
      _phase == _RuntimePhase.terminated || _phase == _RuntimePhase.faulted;
  int get activeCallCount => _activeCallCount;
  int get liveOwnerCount => _liveOwnerCount;

  /// Acquires the isolate's single native lease, rolling back failed attempts.
  void ensureInitialized() {
    if (_phase == _RuntimePhase.initialized) return;
    _checkMayEnter();

    int initResult;
    Object? initError;
    StackTrace? initStackTrace;
    try {
      initResult = _initializeNative();
    } catch (error, stackTrace) {
      initResult = 0;
      initError = error;
      initStackTrace = stackTrace;
    }

    if (initError == null && initResult > 0) {
      _phase = _RuntimePhase.initialized;
      return;
    }

    try {
      final rollbackResult = _shutdownNative();
      if (rollbackResult < 0) {
        _phase = _RuntimePhase.faulted;
        throw Libgit2LifecycleException(
          Libgit2LifecycleOperation.rollback,
          nativeResult: rollbackResult,
          cause: initError,
          causeStackTrace: initStackTrace,
        );
      }
    } on Libgit2LifecycleException {
      rethrow;
    } catch (error, stackTrace) {
      _phase = _RuntimePhase.faulted;
      throw Libgit2LifecycleException(
        Libgit2LifecycleOperation.rollback,
        nativeResult: initResult,
        cause: error,
        causeStackTrace: stackTrace,
      );
    }

    throw Libgit2LifecycleException(
      Libgit2LifecycleOperation.initialize,
      nativeResult: initResult,
      cause: initError,
      causeStackTrace: initStackTrace,
    );
  }

  T withCall<T>(T Function() callback) {
    ensureInitialized();
    _activeCallCount++;
    try {
      return callback();
    } finally {
      _activeCallCount--;
    }
  }

  Libgit2OwnerLease acquireOwner({String? debugLabel}) {
    ensureInitialized();
    _liveOwnerCount++;
    final cleanup = _OwnerCleanup(
      runtime: this,
      debugLabel: debugLabel ?? 'libgit2 owner',
    );
    final lease = Libgit2OwnerLease._(cleanup, _ownerFinalizer);
    _ownerFinalizer.attach(lease, cleanup, detach: cleanup);
    return lease;
  }

  int shutdown() {
    if (_phase == _RuntimePhase.terminated) return _shutdownResult;
    if (_phase == _RuntimePhase.faulted) {
      throw StateError('The libgit2 runtime is faulted and terminal.');
    }
    if (_activeCallCount != 0 || _liveOwnerCount != 0) {
      throw StateError(
        'Cannot shut down libgit2 with $_activeCallCount active call(s) and '
        '$_liveOwnerCount live owner(s).',
      );
    }
    if (_phase == _RuntimePhase.uninitialized) {
      _shutdownResult = 0;
      _phase = _RuntimePhase.terminated;
      return 0;
    }

    try {
      final result = _shutdownNative();
      if (result < 0) {
        _phase = _RuntimePhase.faulted;
        throw Libgit2LifecycleException(
          Libgit2LifecycleOperation.shutdown,
          nativeResult: result,
        );
      }
      _shutdownResult = result;
      _phase = _RuntimePhase.terminated;
      return result;
    } on Libgit2LifecycleException {
      rethrow;
    } catch (error, stackTrace) {
      _phase = _RuntimePhase.faulted;
      throw Libgit2LifecycleException(
        Libgit2LifecycleOperation.shutdown,
        cause: error,
        causeStackTrace: stackTrace,
      );
    }
  }

  void _checkMayEnter() {
    if (_phase == _RuntimePhase.terminated) {
      throw StateError('The libgit2 runtime has already shut down.');
    }
    if (_phase == _RuntimePhase.faulted) {
      throw StateError('The libgit2 runtime is faulted and terminal.');
    }
  }

  void _ownerCompleted() {
    if (_liveOwnerCount <= 0) {
      throw StateError('libgit2 owner accounting underflow.');
    }
    _liveOwnerCount--;
  }

  void _reportOwnerFinalizerError(Object error, StackTrace stackTrace) {
    _onFinalizerError(error, stackTrace);
  }

  static void _finalizeOwner(_OwnerCleanup cleanup) {
    cleanup.releaseFromFinalizer();
  }
}

/// Exact-once logical ownership token for a native resource.
final class Libgit2OwnerLease {
  Libgit2OwnerLease._(this._cleanup, this._finalizer);

  final _OwnerCleanup _cleanup;
  final Finalizer<_OwnerCleanup> _finalizer;

  String get debugLabel => _cleanup.debugLabel;
  bool get isCompleted => _cleanup.isCompleted;

  /// Binds the native destructor once, after successful native construction.
  void bindDestructor(void Function() destructor) {
    _cleanup.bindDestructor(destructor);
  }

  /// Destroys the owner and completes its pin exactly once.
  void release() {
    _cleanup.release();
    _detachIfCompleted();
  }

  /// Non-throwing fallback used by finalizer callbacks and deterministic tests.
  void releaseFromFinalizer() {
    _cleanup.releaseFromFinalizer();
    _detachIfCompleted();
  }

  /// Destroys a partially constructed owner before completing its pin.
  void rollbackConstruction() {
    _cleanup.release();
    _detachIfCompleted();
  }

  /// Completes the pin without destroying ownership transferred to native code.
  void transfer() {
    _cleanup.transfer();
    _detachIfCompleted();
  }

  void _detachIfCompleted() {
    if (_cleanup.isCompleted) {
      _finalizer.detach(_cleanup);
    }
  }
}

final class _OwnerCleanup {
  _OwnerCleanup({required this.runtime, required this.debugLabel});

  final Libgit2RuntimeState runtime;
  final String debugLabel;
  void Function()? _destructor;
  bool _isCompleting = false;
  bool _isCompleted = false;

  bool get isCompleted => _isCompleted;

  void bindDestructor(void Function() destructor) {
    if (_isCompleted) {
      throw StateError('Owner "$debugLabel" has already completed.');
    }
    if (_destructor != null) {
      throw StateError('Owner "$debugLabel" already has a destructor.');
    }
    _destructor = destructor;
  }

  void release() => _complete(invokeDestructor: true);
  void transfer() => _complete(invokeDestructor: false);

  void releaseFromFinalizer() {
    try {
      release();
    } catch (error, stackTrace) {
      runtime._reportOwnerFinalizerError(
        Libgit2LifecycleException(
          Libgit2LifecycleOperation.finalizerCleanup,
          cause: error,
          causeStackTrace: stackTrace,
          ownerLabel: debugLabel,
        ),
        stackTrace,
      );
    }
  }

  void _complete({required bool invokeDestructor}) {
    if (_isCompleted) return;
    if (_isCompleting) {
      throw StateError('Owner "$debugLabel" cleanup is already in progress.');
    }

    _isCompleting = true;
    try {
      if (invokeDestructor) _destructor?.call();
      _isCompleted = true;
      runtime._ownerCompleted();
    } finally {
      _isCompleting = false;
    }
  }
}

enum _RuntimePhase { uninitialized, initialized, terminated, faulted }

void _reportFinalizerError(Object error, StackTrace stackTrace) {
  stderr.writeln('libgit2 finalizer cleanup failed: $error\n$stackTrace');
}

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
  if (Platform.isIOS) return DynamicLibrary.process();

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

String? _cachedPackageRoot;
String _packageRoot() => _cachedPackageRoot ??= _resolvePackageRoot();

void _loadPlatformDependencies(String packageRoot) {
  try {
    if (Platform.isLinux) {
      DynamicLibrary.open(p.join(packageRoot, 'linux', 'libssh2.so'));
    } else if (Platform.isMacOS) {
      // macOS release artifacts link dependencies statically into libgit2.
    } else if (Platform.isWindows) {
      _loadWindowsDependencies(packageRoot);
    }
  } catch (error) {
    stderr.writeln(
      'Failed to load libgit2 dependency: $error\n'
      'Make sure dependent libraries are bundled with the application.',
    );
    rethrow;
  }
}

void _loadWindowsDependencies(String packageRoot) {
  final windowsDir = Directory(p.join(packageRoot, 'windows'));
  if (!windowsDir.existsSync()) {
    DynamicLibrary.open(p.join(windowsDir.path, 'libssh2.dll'));
    return;
  }

  for (final prefix in ['libcrypto', 'libssl']) {
    final libraries =
        windowsDir
            .listSync()
            .whereType<File>()
            .where(
              (file) =>
                  p.basename(file.path).toLowerCase().startsWith(prefix) &&
                  p.extension(file.path).toLowerCase() == '.dll',
            )
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));
    for (final library in libraries) {
      DynamicLibrary.open(library.path);
    }
  }
  DynamicLibrary.open(p.join(windowsDir.path, 'libssh2.dll'));
}

String _resolvePackageRoot() {
  final override = Platform.environment['GIT2DART_BINARIES_PACKAGE_ROOT'];
  if (override != null && override.isNotEmpty) {
    return Directory(override).absolute.path;
  }

  final packageUri = _tryResolvePackageUri();
  if (packageUri != null) {
    return File.fromUri(packageUri).parent.parent.absolute.path;
  }

  final configRoot = _packageRootFromConfig();
  if (configRoot != null) return configRoot;
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
  if (configUri == null) return null;

  try {
    final file = File.fromUri(configUri);
    if (!file.existsSync()) return null;
    final decoded = jsonDecode(file.readAsStringSync());
    if (decoded is! Map<String, dynamic>) return null;
    final packages = decoded['packages'];
    if (packages is! List) return null;

    for (final entry in packages) {
      if (entry is! Map<String, dynamic> ||
          entry['name'] != 'git2dart_binaries') {
        continue;
      }
      final rootUri = entry['rootUri'];
      if (rootUri is! String) continue;
      return File.fromUri(
        configUri.resolveUri(Uri.parse(rootUri)),
      ).absolute.path;
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
    // Fall through to the environment and executable argument fallbacks.
  }

  final environmentPath = Platform.environment['DART_PACKAGE_CONFIG'];
  if (environmentPath != null && environmentPath.isNotEmpty) {
    return File(environmentPath).absolute.uri;
  }
  for (final argument in Platform.executableArguments) {
    if (argument.startsWith('--packages=')) {
      return File(argument.substring('--packages='.length)).absolute.uri;
    }
  }
  return null;
}
