import 'dart:ffi' as ffi;
import 'dart:io' show Platform;

import 'package:ffi/ffi.dart';
import 'package:git2dart_binaries/src/bindings.dart';
import 'package:git2dart_binaries/src/extensions.dart';
import 'package:git2dart_binaries/src/opts_bindings.dart';
import 'package:test/test.dart';

void main() {
  late Libgit2Opts opts;
  late ffi.DynamicLibrary library;
  late Libgit2 libgit2;

  setUp(() {
    // Load the real libgit2 library based on the platform
    if (Platform.isWindows) {
      library = ffi.DynamicLibrary.open('windows/libgit2.dll');
    } else if (Platform.isMacOS) {
      library = ffi.DynamicLibrary.open('macos/libgit2.dylib');
    } else {
      library = ffi.DynamicLibrary.open('linux/libgit2.so');
    }

    libgit2 = Libgit2(library);
    libgit2.git_libgit2_init();
    opts = Libgit2Opts(library);
  });

  group('Memory Window Integration Tests', () {
    test('get and set mwindow size', () {
      final size = malloc<ffi.Int>();

      // Get initial size
      expect(
        opts.git_libgit2_opts_get_mwindow_size(size),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );
      final initialSize = size.value;

      // Set new size
      final newSize = initialSize + 1024;
      expect(
        opts.git_libgit2_opts_set_mwindow_size(newSize),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );

      // Verify size was changed
      expect(
        opts.git_libgit2_opts_get_mwindow_size(size),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );
      expect(
        size.value,
        equals(newSize),
        reason: libgit2.getLastError()?.toString(),
      );

      // Restore original size
      expect(
        opts.git_libgit2_opts_set_mwindow_size(initialSize),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );
      malloc.free(size);
    });

    test('get and set mwindow mapped limit', () {
      final limit = malloc<ffi.Int>();

      // Get initial limit
      expect(
        opts.git_libgit2_opts_get_mwindow_mapped_limit(limit),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );
      final initialLimit = limit.value;

      // Set new limit
      final newLimit = initialLimit + 2048;
      expect(
        opts.git_libgit2_opts_set_mwindow_mapped_limit(newLimit),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );

      // Verify limit was changed
      expect(
        opts.git_libgit2_opts_get_mwindow_mapped_limit(limit),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );
      expect(
        limit.value,
        equals(newLimit),
        reason: libgit2.getLastError()?.toString(),
      );

      // Restore original limit
      expect(
        opts.git_libgit2_opts_set_mwindow_mapped_limit(initialLimit),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );
      malloc.free(limit);
    });
  });

  group('Cache Integration Tests', () {
    test('get and set cache memory limits', () {
      final current = malloc<ffi.Int>();
      final allowed = malloc<ffi.Int>();

      // Get initial values
      expect(
        opts.git_libgit2_opts_get_cached_memory(current, allowed),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );
      final initialAllowed = allowed.value;

      // Set new cache size
      final newSize = initialAllowed + 1024 * 1024; // Increase by 1MB
      expect(
        opts.git_libgit2_opts_set_cache_max_size(newSize),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );

      // Verify change
      expect(
        opts.git_libgit2_opts_get_cached_memory(current, allowed),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );
      expect(
        allowed.value,
        equals(newSize),
        reason: libgit2.getLastError()?.toString(),
      );

      // Restore original size
      expect(
        opts.git_libgit2_opts_set_cache_max_size(initialAllowed),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );

      malloc.free(current);
      malloc.free(allowed);
    });

    test('enable and disable caching', () {
      // Enable caching
      expect(
        opts.git_libgit2_opts_enable_caching(1),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );

      // Disable caching
      expect(
        opts.git_libgit2_opts_enable_caching(0),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );

      // Re-enable caching (default state)
      expect(
        opts.git_libgit2_opts_enable_caching(1),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );
    });
  });

  group('Search Path Integration Tests', () {
    test('get and set search path', () {
      final buf = malloc<git_buf>();
      buf.ref.ptr = ffi.nullptr;
      buf.ref.size = 0;
      buf.ref.reserved = 0;

      // Get system level search path
      expect(
        opts.git_libgit2_opts_get_search_path(2, buf),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );

      // Set a new search path
      final pathStr = '/tmp/git2dart_test';
      final testPath = pathStr.toNativeUtf8().cast<ffi.Char>();

      expect(
        opts.git_libgit2_opts_set_search_path(2, testPath),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );

      buf.ref.ptr = ffi.nullptr;
      buf.ref.size = 0;
      buf.ref.reserved = 0;

      // Get and verify the new path
      expect(opts.git_libgit2_opts_get_search_path(2, buf), equals(0));

      // Cleanup
      if (buf.ref.ptr != ffi.nullptr) {
        malloc.free(buf.ref.ptr);
      }
      malloc.free(buf);
      malloc.free(testPath);
    });
  });

  group('User Agent Integration Tests', () {
    test('get and set user agent', () {
      final buf = malloc<git_buf>();
      buf.ref.ptr = ffi.nullptr;
      buf.ref.size = 0;
      buf.ref.reserved = 0;

      // Get current user agent
      expect(
        opts.git_libgit2_opts_get_user_agent(buf),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );

      // Set new user agent
      final newAgent = malloc<ffi.Char>();
      final agentStr = 'git2dart-test/1.0';
      newAgent.value = agentStr.codeUnitAt(0);

      expect(
        opts.git_libgit2_opts_set_user_agent(newAgent),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );

      // Get and verify new user agent
      expect(
        opts.git_libgit2_opts_get_user_agent(buf),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );

      // Cleanup
      if (buf.ref.ptr != ffi.nullptr) {
        malloc.free(buf.ref.ptr);
      }
      malloc.free(buf);
      malloc.free(newAgent);
    });
  });

  group('Pack File Integration Tests', () {
    test('get and set pack max objects', () {
      final maxObjects = malloc<ffi.Int>();

      // Get initial value
      expect(
        opts.git_libgit2_opts_get_pack_max_objects(maxObjects),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );
      final initialMax = maxObjects.value;

      // Set new value
      final newMax = initialMax + 1000;
      expect(
        opts.git_libgit2_opts_set_pack_max_objects(newMax),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );

      // Verify change
      expect(
        opts.git_libgit2_opts_get_pack_max_objects(maxObjects),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );
      expect(
        maxObjects.value,
        equals(newMax),
        reason: libgit2.getLastError()?.toString(),
      );

      // Restore original value
      expect(
        opts.git_libgit2_opts_set_pack_max_objects(initialMax),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );
      malloc.free(maxObjects);
    });
  });

  group('Owner Validation Integration Tests', () {
    test('get and set owner validation', () {
      final enabled = malloc<ffi.Int>();

      // Get initial state
      expect(
        opts.git_libgit2_opts_get_owner_validation(enabled),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );
      final initialState = enabled.value;

      // Toggle state
      expect(
        opts.git_libgit2_opts_set_owner_validation(1 - initialState),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );

      // Verify change
      expect(
        opts.git_libgit2_opts_get_owner_validation(enabled),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );
      expect(
        enabled.value,
        equals(1 - initialState),
        reason: libgit2.getLastError()?.toString(),
      );

      // Restore original state
      expect(
        opts.git_libgit2_opts_set_owner_validation(initialState),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );
      malloc.free(enabled);
    });
  });

  group('Extensions Integration Tests', () {
    test('get extensions', () {
      final extensions = calloc<git_strarray>();

      // Get supported extensions
      expect(
        opts.git_libgit2_opts_get_extensions(extensions),
        equals(0),
        reason: libgit2.getLastError()?.toString(),
      );

      // Cleanup
      if (extensions.ref.strings != ffi.nullptr) {
        for (var i = 0; i < extensions.ref.count; i++) {
          final strPtr = extensions.ref.strings.elementAt(i);
          if (strPtr.value != ffi.nullptr) {
            malloc.free(strPtr.value);
          }
        }
        malloc.free(extensions.ref.strings);
      }
      malloc.free(extensions);
    });
  });
}
