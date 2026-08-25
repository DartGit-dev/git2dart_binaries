import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:git2dart_binaries/src/bindings.dart';
import 'package:git2dart_binaries/src/extensions.dart';
import 'package:git2dart_binaries/src/runtime.dart';

import 'support/behavior_proof_fixture.dart';

void main() {
  final libgit2 = libgit2Runtime.bindings;
  final libgit2Opts = libgit2Runtime.options;

  tearDownAll(libgit2Runtime.shutdown);

  test('serialized ABI probe preserves a value above uint32', () async {
    final packageRoot = Platform.environment['GIT2DART_BINARIES_PACKAGE_ROOT'];
    if (packageRoot == null) {
      stdout.writeln(
        'abi-evidence: unavailable (no declared native package payload)',
      );
      return;
    }
    final fixture = await BehaviorProofFixture.create('abi-proof-');
    try {
      final result = await fixture.runBounded(
        dartExecutable(),
        <String>[
          '--packages=${File('.dart_tool/package_config.json').absolute.path}',
          File('test/fixtures/abi_probe/abi_probe.dart').absolute.path,
        ],
        environment: <String, String>{
          'GIT2DART_BINARIES_PACKAGE_ROOT': packageRoot,
        },
      );
      expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
      final record =
          jsonDecode((result.stdout as String).trim()) as Map<String, dynamic>;
      if (record['availability'] == 'unavailable') {
        expect(record['pointer_width'], isNot(64));
        return;
      }
      expect(record['submitted_size'], greaterThan(0xffffffff));
      expect(record['observed_size'], record['submitted_size']);
      expect(record['pointer_width'], 64);
    } finally {
      await fixture.dispose();
    }
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
