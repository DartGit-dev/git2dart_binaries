import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:git2dart_binaries/src/runtime.dart';

void main() {
  const submitted = 0x100000011;
  if (ffi.sizeOf<ffi.IntPtr>() != 8) {
    stdout.writeln(
      jsonEncode(<String, Object>{
        'availability': 'unavailable',
        'pointer_width': ffi.sizeOf<ffi.IntPtr>() * 8,
        'submitted_size': submitted,
      }),
    );
    return;
  }

  final observed = calloc<ffi.Size>();
  int? original;
  try {
    final options = libgit2Runtime.options;
    final getResult = options.git_libgit2_opts_get_mwindow_file_limit(observed);
    if (getResult != 0) throw StateError('get-size failed: $getResult');
    original = observed.value;
    final setResult = options.git_libgit2_opts_set_mwindow_file_limit(
      submitted,
    );
    if (setResult != 0) throw StateError('set-size failed: $setResult');
    final observeResult = options.git_libgit2_opts_get_mwindow_file_limit(
      observed,
    );
    if (observeResult != 0) {
      throw StateError('observe-size failed: $observeResult');
    }
    stdout.writeln(
      jsonEncode(<String, Object>{
        'availability': 'available',
        'pointer_width': ffi.sizeOf<ffi.IntPtr>() * 8,
        'submitted_size': submitted,
        'observed_size': observed.value,
      }),
    );
    if (observed.value != submitted) exitCode = 2;
  } catch (error) {
    stderr.writeln('abi-probe-failed: ${error.runtimeType}');
    exitCode = 1;
  } finally {
    if (original != null) {
      libgit2Runtime.options.git_libgit2_opts_set_mwindow_file_limit(original);
    }
    calloc.free(observed);
    if (libgit2Runtime.isInitialized && !libgit2Runtime.isTerminated) {
      libgit2Runtime.shutdown();
    }
  }
}
