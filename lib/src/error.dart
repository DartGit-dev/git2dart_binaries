import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart_binaries/src/bindings.dart';

/// Native lifecycle transition that failed.
enum Libgit2LifecycleOperation {
  initialize,
  rollback,
  shutdown,
  finalizerCleanup,
}

/// Stable diagnostic error for checked libgit2 lifecycle failures.
final class Libgit2LifecycleException implements Exception {
  const Libgit2LifecycleException(
    this.operation, {
    this.nativeResult,
    this.cause,
    this.causeStackTrace,
    this.ownerLabel,
  });

  final Libgit2LifecycleOperation operation;
  final int? nativeResult;
  final Object? cause;
  final StackTrace? causeStackTrace;
  final String? ownerLabel;

  @override
  String toString() {
    final details = <String>[
      'operation: ${operation.name}',
      if (nativeResult != null) 'nativeResult: $nativeResult',
      if (ownerLabel != null) 'owner: $ownerLabel',
      if (cause != null) 'cause: $cause',
    ];
    return 'Libgit2LifecycleException(${details.join(', ')})';
  }
}

/// Represents an error that occurred in libgit2.
///
/// This class provides access to the last error that occurred in libgit2
/// operations.
/// It wraps the native `git_error` structure and provides a Dart-friendly
/// interface to access error information.
class LibGit2Error {
  /// Creates a new instance of [LibGit2Error] from a native error pointer.
  ///
  /// Note: This constructor is for internal use only.
  LibGit2Error(this._errorPointer);

  final Pointer<git_error> _errorPointer;

  /// Gets the error message associated with this error.
  String get message =>
      _errorPointer.ref.message == nullptr
          ? ''
          : _errorPointer.ref.message.cast<Utf8>().toDartString();

  /// Gets the error class associated with this error.
  git_error_t get errorClass => git_error_t.fromValue(_errorPointer.ref.klass);

  @override
  String toString() => "error: $errorClass: $message";
}
