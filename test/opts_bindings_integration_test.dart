import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:git2dart_binaries/src/bindings.dart';
import 'package:git2dart_binaries/src/extensions.dart';
import 'package:git2dart_binaries/src/runtime.dart';

void main() {
  final libgit2 = libgit2Runtime.bindings;
  final libgit2Opts = libgit2Runtime.options;

  tearDownAll(libgit2Runtime.shutdown);

  group('Memory Window Integration Tests', () {
    test('get and set mwindow size', () {
      final size = calloc<ffi.Size>();
      try {
        // Get initial size
        expect(
          libgit2Opts.git_libgit2_opts_get_mwindow_size(size),
          equals(0),
          reason: libgit2.getLastError()?.toString(),
        );
        final initialSize = size.value;
        addTearDown(() {
          expect(
            libgit2Opts.git_libgit2_opts_set_mwindow_size(initialSize),
            equals(0),
            reason: libgit2.getLastError()?.toString(),
          );
        });

        // Set new size
        final newSize = initialSize + (1 << 32);
        expect(
          libgit2Opts.git_libgit2_opts_set_mwindow_size(newSize),
          equals(0),
          reason: libgit2.getLastError()?.toString(),
        );

        // Verify size was changed
        expect(
          libgit2Opts.git_libgit2_opts_get_mwindow_size(size),
          equals(0),
          reason: libgit2.getLastError()?.toString(),
        );
        expect(
          size.value,
          equals(newSize),
          reason: libgit2.getLastError()?.toString(),
        );
      } finally {
        calloc.free(size);
      }
    });

    test('get and set mwindow mapped limit', () {
      final limit = calloc<ffi.Size>();

      // Get initial limit
      expect(
        libgit2Opts.git_libgit2_opts_get_mwindow_mapped_limit(limit),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );
      final initialLimit = limit.value;
      addTearDown(() {
        expect(
          libgit2Opts.git_libgit2_opts_set_mwindow_mapped_limit(initialLimit),
          equals(0),
          reason: libgit2.getLastError()?.toString(),
        );
      });

      // Set new limit
      final newLimit = initialLimit + (1 << 32);
      expect(
        libgit2Opts.git_libgit2_opts_set_mwindow_mapped_limit(newLimit),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );

      // Verify limit was changed
      expect(
        libgit2Opts.git_libgit2_opts_get_mwindow_mapped_limit(limit),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );
      expect(
        limit.value,
        equals(newLimit),
        reason: libgit2.getLastError()?.toString(),
      );

      calloc.free(limit);
    });

    test('get and set mwindow file limit with a pointer-width value', () {
      final limit = calloc<ffi.Size>();
      try {
        expect(
          libgit2Opts.git_libgit2_opts_get_mwindow_file_limit(limit),
          equals(0),
          reason: libgit2.getLastError()?.toString(),
        );
        final initialLimit = limit.value;
        addTearDown(() {
          expect(
            libgit2Opts.git_libgit2_opts_set_mwindow_file_limit(initialLimit),
            equals(0),
            reason: libgit2.getLastError()?.toString(),
          );
        });
        final newLimit = initialLimit + (1 << 32);
        expect(
          libgit2Opts.git_libgit2_opts_set_mwindow_file_limit(newLimit),
          equals(0),
          reason: libgit2.getLastError()?.toString(),
        );
        expect(
          libgit2Opts.git_libgit2_opts_get_mwindow_file_limit(limit),
          equals(0),
          reason: libgit2.getLastError()?.toString(),
        );
        expect(limit.value, equals(newLimit));
      } finally {
        calloc.free(limit);
      }
    });
  });

  group('Cache Integration Tests', () {
    test('get and set cache memory limits', () {
      final current = calloc<ffi.IntPtr>();
      final allowed = calloc<ffi.IntPtr>();

      // Get initial values
      expect(
        libgit2Opts.git_libgit2_opts_get_cached_memory(current, allowed),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );
      final initialAllowed = allowed.value;
      addTearDown(() {
        expect(
          libgit2Opts.git_libgit2_opts_set_cache_max_size(initialAllowed),
          equals(0),
          reason: libgit2.getLastError()?.toString(),
        );
      });

      // Set new cache size
      final newSize = initialAllowed + (1 << 32);
      expect(
        libgit2Opts.git_libgit2_opts_set_cache_max_size(newSize),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );

      // Verify change
      expect(
        libgit2Opts.git_libgit2_opts_get_cached_memory(current, allowed),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );
      expect(
        allowed.value,
        equals(newSize),
        reason: libgit2.getLastError()?.toString(),
      );

      calloc.free(current);
      calloc.free(allowed);
    });

    test('declares cache object limit with a pointer-width value', () {
      final wrapper = File('lib/src/opts_bindings.dart').readAsStringSync();
      expect(wrapper, contains('ffi.VarArgs<(ffi.Int, ffi.Size)>'));
    });
  });

  group('Search Path Integration Tests', () {
    test('get and set search path', () {
      final buf = calloc<git_buf>();
      final pathStr = '/tmp/git2dart_test';
      final testPath = pathStr.toNativeUtf8().cast<ffi.Char>();
      ffi.Pointer<ffi.Char>? initialPath;
      var pathChanged = false;

      try {
        expect(
          libgit2Opts.git_libgit2_opts_get_search_path(2, buf),
          equals(0),
          reason: libgit2.getLastError()?.toString(),
        );
        initialPath =
            buf.ref.ptr
                .cast<Utf8>()
                .toDartString()
                .toNativeUtf8()
                .cast<ffi.Char>();
        libgit2.git_buf_dispose(buf);
        buf.ref.ptr = ffi.nullptr;
        buf.ref.size = 0;
        buf.ref.reserved = 0;

        expect(
          libgit2Opts.git_libgit2_opts_set_search_path(2, testPath),
          equals(0),
          reason: libgit2.getLastError()?.toString(),
        );
        pathChanged = true;

        expect(
          libgit2Opts.git_libgit2_opts_get_search_path(2, buf),
          equals(0),
          reason: libgit2.getLastError()?.toString(),
        );
      } finally {
        if (pathChanged && initialPath != null) {
          expect(
            libgit2Opts.git_libgit2_opts_set_search_path(2, initialPath),
            equals(0),
            reason: libgit2.getLastError()?.toString(),
          );
        }
        libgit2.git_buf_dispose(buf);
        calloc.free(buf);
        if (initialPath != null) calloc.free(initialPath);
        calloc.free(testPath);
      }
    });
  });

  group('User Agent Integration Tests', () {
    test('get and set user agent', () {
      final buf = calloc<git_buf>();
      buf.ref.ptr = ffi.nullptr;
      buf.ref.size = 0;
      buf.ref.reserved = 0;
      final newAgent = 'git2dart-test/1.0'.toNativeUtf8().cast<ffi.Char>();
      ffi.Pointer<ffi.Char>? initialAgent;
      var userAgentChanged = false;

      try {
        expect(
          libgit2Opts.git_libgit2_opts_get_user_agent(buf),
          equals(0),
          reason: libgit2.getLastError()?.toString(),
        );
        initialAgent =
            buf.ref.ptr
                .cast<Utf8>()
                .toDartString()
                .toNativeUtf8()
                .cast<ffi.Char>();
        libgit2.git_buf_dispose(buf);
        buf.ref.ptr = ffi.nullptr;
        buf.ref.size = 0;
        buf.ref.reserved = 0;

        expect(
          libgit2Opts.git_libgit2_opts_set_user_agent(newAgent),
          equals(0),
          reason: libgit2.getLastError()?.toString(),
        );
        userAgentChanged = true;

        expect(
          libgit2Opts.git_libgit2_opts_get_user_agent(buf),
          equals(0),
          reason: libgit2.getLastError()?.toString(),
        );
      } finally {
        if (userAgentChanged && initialAgent != null) {
          expect(
            libgit2Opts.git_libgit2_opts_set_user_agent(initialAgent),
            equals(0),
            reason: libgit2.getLastError()?.toString(),
          );
        }
        libgit2.git_buf_dispose(buf);
        calloc.free(buf);
        if (initialAgent != null) calloc.free(initialAgent);
        calloc.free(newAgent);
      }
    });
  });

  group('Pack File Integration Tests', () {
    test('get and set pack max objects', () {
      final maxObjects = calloc<ffi.Size>();

      // Get initial value
      expect(
        libgit2Opts.git_libgit2_opts_get_pack_max_objects(maxObjects),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );
      final initialMax = maxObjects.value;
      addTearDown(() {
        expect(
          libgit2Opts.git_libgit2_opts_set_pack_max_objects(initialMax),
          equals(0),
          reason: libgit2.getLastError()?.toString(),
        );
      });

      // Set new value
      final newMax = initialMax + (1 << 32);
      expect(
        libgit2Opts.git_libgit2_opts_set_pack_max_objects(newMax),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );

      // Verify change
      expect(
        libgit2Opts.git_libgit2_opts_get_pack_max_objects(maxObjects),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );
      expect(
        maxObjects.value,
        equals(newMax),
        reason: libgit2.getLastError()?.toString(),
      );

      calloc.free(maxObjects);
    });

    test('get and set pack max object size', () {
      final maxObjectSize = calloc<ffi.Size>();

      expect(
        libgit2Opts.git_libgit2_opts_get_pack_max_object_size(maxObjectSize),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );
      final initialMax = maxObjectSize.value;
      addTearDown(() {
        libgit2Opts.git_libgit2_opts_set_pack_max_object_size(initialMax);
        calloc.free(maxObjectSize);
      });

      const newMax = 64 * 1024 * 1024;
      expect(
        libgit2Opts.git_libgit2_opts_set_pack_max_object_size(newMax),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );
      expect(
        libgit2Opts.git_libgit2_opts_get_pack_max_object_size(maxObjectSize),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );
      expect(maxObjectSize.value, equals(newMax));
    });

    test('rejects a negative pack max object size', () {
      expect(
        () => libgit2Opts.git_libgit2_opts_set_pack_max_object_size(-1),
        throwsRangeError,
      );
    });
  });

  group('Owner Validation Integration Tests', () {
    test('get and set owner validation', () {
      final enabled = calloc<ffi.Int>();

      // Get initial state
      expect(
        libgit2Opts.git_libgit2_opts_get_owner_validation(enabled),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );
      final initialState = enabled.value;
      addTearDown(() {
        expect(
          libgit2Opts.git_libgit2_opts_set_owner_validation(initialState),
          equals(0),
          reason: libgit2.getLastError()?.toString(),
        );
      });

      // Toggle state
      expect(
        libgit2Opts.git_libgit2_opts_set_owner_validation(1 - initialState),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );

      // Verify change
      expect(
        libgit2Opts.git_libgit2_opts_get_owner_validation(enabled),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );
      expect(
        enabled.value,
        equals(1 - initialState),
        reason: libgit2.getLastError()?.toString(),
      );

      calloc.free(enabled);
    });
  });

  group('Extensions Integration Tests', () {
    test('get extensions', () {
      final extensions = calloc<git_strarray>();

      // Get supported extensions
      expect(
        libgit2Opts.git_libgit2_opts_get_extensions(extensions),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );

      // Cleanup
      libgit2.git_strarray_dispose(extensions);
      calloc.free(extensions);
    });
  });
}
