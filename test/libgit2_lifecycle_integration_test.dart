import 'dart:io';
import 'dart:isolate';

import 'package:git2dart_binaries/src/runtime.dart';
import 'package:test/test.dart';

void main() {
  test(
    'two isolates own independent increments and remain composable',
    () async {
      final first = await _LifecycleWorker.spawn();
      final second = await _LifecycleWorker.spawn();
      addTearDown(first.dispose);
      addTearDown(second.dispose);

      final firstCount = await first.command('initialize');
      final secondCount = await second.command('initialize');

      expect(firstCount, greaterThanOrEqualTo(1));
      expect(secondCount, firstCount + 1);

      final remainingAfterFirst = await first.command('shutdown');
      expect(remainingAfterFirst, firstCount);

      final secondStillUsable = await second.command('probe');
      expect(secondStillUsable, firstCount);

      final remainingAfterSecond = await second.command('shutdown');
      expect(remainingAfterSecond, firstCount - 1);
    },
    skip:
        _nativeLifecycleArtifactAvailable
            ? false
            : 'Requires an expanded package with native libgit2 artifacts.',
  );
}

bool get _nativeLifecycleArtifactAvailable {
  if (Platform.environment['GIT2DART_RUN_NATIVE_LIFECYCLE_TESTS'] == '1') {
    return true;
  }
  if (Platform.isWindows) {
    return File('windows/libgit2.dll').existsSync();
  }
  if (Platform.isMacOS) {
    return File('macos/libgit2.dylib').existsSync();
  }
  if (Platform.isLinux) {
    return File('linux/libgit2.so').existsSync();
  }
  return false;
}

Future<void> _workerMain(SendPort ready) async {
  final commands = ReceivePort();
  ready.send(commands.sendPort);

  await for (final message in commands) {
    final request = message as List<Object?>;
    final operation = request[0]! as String;
    final reply = request[1]! as SendPort;

    try {
      switch (operation) {
        case 'initialize':
        case 'probe':
          reply.send(['ok', _probeProcessCount()]);
        case 'shutdown':
          reply.send(['ok', libgit2Runtime.shutdown()]);
        case 'close':
          reply.send(['ok', libgit2Runtime.shutdown()]);
          commands.close();
        default:
          throw StateError('Unknown lifecycle worker operation: $operation');
      }
    } catch (error, stackTrace) {
      reply.send(['error', '$error', '$stackTrace']);
    }
  }
}

int _probeProcessCount() {
  final runtime = libgit2Runtime;
  if (!identical(runtime.bindings, runtime.bindings)) {
    throw StateError('Repeated binding access did not reuse the instance.');
  }
  if (!identical(runtime.options, runtime.options)) {
    throw StateError('Repeated options access did not reuse the instance.');
  }

  return runtime.withCall((bindings) {
    final afterProbeInit = bindings.git_libgit2_init();
    if (afterProbeInit < 1) {
      throw StateError('Controlled init probe failed: $afterProbeInit');
    }

    final afterProbeShutdown = bindings.git_libgit2_shutdown();
    if (afterProbeShutdown != afterProbeInit - 1) {
      throw StateError(
        'Controlled probe was not symmetric: '
        '$afterProbeInit -> $afterProbeShutdown',
      );
    }
    return afterProbeShutdown;
  });
}

final class _LifecycleWorker {
  _LifecycleWorker(this._isolate, this._commands);

  final Isolate _isolate;
  final SendPort _commands;
  bool _disposed = false;

  static Future<_LifecycleWorker> spawn() async {
    final ready = ReceivePort();
    final isolate = await Isolate.spawn(_workerMain, ready.sendPort);
    final commands = await ready.first as SendPort;
    ready.close();
    return _LifecycleWorker(isolate, commands);
  }

  Future<int> command(String operation) async {
    final reply = ReceivePort();
    _commands.send([operation, reply.sendPort]);
    final response =
        await reply.first.timeout(const Duration(seconds: 15)) as List<Object?>;
    reply.close();

    if (response[0] != 'ok') {
      throw StateError('${response[1]}\n${response[2]}');
    }
    return response[1]! as int;
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    try {
      await command('close').timeout(const Duration(seconds: 5));
    } catch (_) {
      // The isolate may already have closed after an earlier shutdown command.
    } finally {
      _isolate.kill(priority: Isolate.immediate);
    }
  }
}
