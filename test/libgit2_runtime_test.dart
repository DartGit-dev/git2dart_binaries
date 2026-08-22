import 'package:git2dart_binaries/src/runtime.dart';
import 'package:test/test.dart';

void main() {
  group('checked initialization', () {
    test('commits exactly one positive native lease', () {
      final native = _FakeNativeLifecycle(initResults: [1]);
      final runtime = _runtimeFor(native);

      expect(runtime.isInitialized, isFalse);

      runtime.ensureInitialized();

      expect(runtime.isInitialized, isTrue);
      expect(native.initCalls, 1);
      expect(native.shutdownCalls, 0);
    });

    test('rolls back a failed init once without caching the failure', () {
      final native = _FakeNativeLifecycle(
        initResults: [-7, 1],
        shutdownResults: [0],
      );
      final runtime = _runtimeFor(native);

      expect(
        runtime.ensureInitialized,
        throwsA(isA<Libgit2LifecycleException>()),
      );
      expect(runtime.isInitialized, isFalse);
      expect(native.initCalls, 1);
      expect(native.shutdownCalls, 1);

      runtime.ensureInitialized();

      expect(runtime.isInitialized, isTrue);
      expect(native.initCalls, 2);
      expect(native.shutdownCalls, 1);
    });

    test('zero is an unexpected init result and is rolled back once', () {
      final native = _FakeNativeLifecycle(
        initResults: [0],
        shutdownResults: [0],
      );
      final runtime = _runtimeFor(native);

      expect(
        runtime.ensureInitialized,
        throwsA(isA<Libgit2LifecycleException>()),
      );

      expect(runtime.isInitialized, isFalse);
      expect(native.initCalls, 1);
      expect(native.shutdownCalls, 1);
    });

    test('a failed rollback faults the runtime and is never retried', () {
      final native = _FakeNativeLifecycle(
        initResults: [-7],
        shutdownResults: [-9],
      );
      final runtime = _runtimeFor(native);

      expect(
        runtime.ensureInitialized,
        throwsA(isA<Libgit2LifecycleException>()),
      );
      expect(runtime.isTerminated, isTrue);

      expect(runtime.ensureInitialized, throwsStateError);
      expect(native.initCalls, 1);
      expect(native.shutdownCalls, 1);
    });
  });

  group('lease reuse and transient calls', () {
    test('logical use never adds another native increment', () {
      final native = _FakeNativeLifecycle(initResults: [1]);
      final runtime = _runtimeFor(native);

      runtime.ensureInitialized();
      runtime.ensureInitialized();
      runtime.withCall(() {});
      final owner = runtime.acquireOwner(debugLabel: 'repository');
      owner.transfer();

      expect(native.initCalls, 1);
      expect(runtime.activeCallCount, 0);
      expect(runtime.liveOwnerCount, 0);
    });

    test('transient pin is released in finally when the call throws', () {
      final runtime = _runtimeFor(_FakeNativeLifecycle());

      expect(
        () => runtime.withCall<void>(() {
          expect(runtime.activeCallCount, 1);
          throw StateError('operation failed');
        }),
        throwsStateError,
      );

      expect(runtime.activeCallCount, 0);
    });

    test('a transient call rejects reentrant shutdown unchanged', () {
      final native = _FakeNativeLifecycle(shutdownResults: [0]);
      final runtime = _runtimeFor(native);

      runtime.withCall<void>(() {
        expect(runtime.shutdown, throwsStateError);
        expect(native.shutdownCalls, 0);
      });

      expect(runtime.shutdown(), 0);
      expect(native.shutdownCalls, 1);
    });
  });

  group('persistent owner cleanup', () {
    test('explicit and fallback cleanup complete exactly once', () {
      final runtime = _runtimeFor(_FakeNativeLifecycle());
      final owner = runtime.acquireOwner(debugLabel: 'repository');
      var destructorCalls = 0;
      owner.bindDestructor(() => destructorCalls++);

      owner.release();
      owner.release();
      owner.releaseFromFinalizer();

      expect(destructorCalls, 1);
      expect(runtime.liveOwnerCount, 0);
    });

    test('construction rollback destroys once before unpinning', () {
      final runtime = _runtimeFor(_FakeNativeLifecycle());
      final owner = runtime.acquireOwner(debugLabel: 'partial repository');
      var destructorCalls = 0;
      owner.bindDestructor(() => destructorCalls++);

      owner.rollbackConstruction();
      owner.rollbackConstruction();

      expect(destructorCalls, 1);
      expect(runtime.liveOwnerCount, 0);
    });

    test('transfer unpins without destroying native ownership', () {
      final runtime = _runtimeFor(_FakeNativeLifecycle());
      final owner = runtime.acquireOwner(debugLabel: 'transferred repository');
      var destructorCalls = 0;
      owner.bindDestructor(() => destructorCalls++);

      owner.transfer();
      owner.releaseFromFinalizer();

      expect(destructorCalls, 0);
      expect(runtime.liveOwnerCount, 0);
    });

    test('cleanup failure retains the pin and finalizer reports safely', () {
      final native = _FakeNativeLifecycle();
      final runtime = _runtimeFor(native);
      final owner = runtime.acquireOwner(debugLabel: 'failed cleanup');
      owner.bindDestructor(() => throw StateError('native free failed'));

      expect(owner.release, throwsStateError);
      expect(runtime.liveOwnerCount, 1);
      expect(runtime.shutdown, throwsStateError);
      expect(native.shutdownCalls, 0);

      expect(owner.releaseFromFinalizer, returnsNormally);
      expect(native.finalizerErrors, hasLength(1));
      expect(runtime.liveOwnerCount, 1);
    });
  });

  group('guarded terminal shutdown', () {
    test('live owner rejects shutdown without a native transition', () {
      final native = _FakeNativeLifecycle();
      final runtime = _runtimeFor(native);
      runtime.acquireOwner(debugLabel: 'repository');

      expect(runtime.shutdown, throwsStateError);
      expect(native.shutdownCalls, 0);
    });

    test('successful shutdown is idempotent and stores remaining count', () {
      final native = _FakeNativeLifecycle(shutdownResults: [2]);
      final runtime = _runtimeFor(native)..ensureInitialized();

      expect(runtime.shutdown(), 2);
      expect(runtime.shutdown(), 2);
      expect(native.shutdownCalls, 1);
      expect(runtime.isTerminated, isTrue);
    });

    test('managed entry is rejected after successful shutdown', () {
      final native = _FakeNativeLifecycle(shutdownResults: [0]);
      final runtime = _runtimeFor(native)..ensureInitialized();
      runtime.shutdown();

      expect(runtime.ensureInitialized, throwsStateError);
      expect(() => runtime.withCall(() {}), throwsStateError);
      expect(runtime.acquireOwner, throwsStateError);
      expect(native.initCalls, 1);
      expect(native.shutdownCalls, 1);
    });

    test('ambiguous native shutdown faults terminally without retry', () {
      final native = _FakeNativeLifecycle(shutdownResults: [-8]);
      final runtime = _runtimeFor(native)..ensureInitialized();

      expect(runtime.shutdown, throwsA(isA<Libgit2LifecycleException>()));
      expect(runtime.isTerminated, isTrue);

      expect(runtime.shutdown, throwsStateError);
      expect(native.shutdownCalls, 1);
    });
  });
}

Libgit2RuntimeState _runtimeFor(_FakeNativeLifecycle native) =>
    Libgit2RuntimeState.forTesting(
      initialize: native.initialize,
      shutdown: native.shutdown,
      onFinalizerError: native.recordFinalizerError,
    );

final class _FakeNativeLifecycle {
  _FakeNativeLifecycle({
    List<int> initResults = const [1],
    List<int> shutdownResults = const [0],
  }) : _initResults = [...initResults],
       _shutdownResults = [...shutdownResults];

  final List<int> _initResults;
  final List<int> _shutdownResults;
  final List<Object> finalizerErrors = [];

  int initCalls = 0;
  int shutdownCalls = 0;

  int initialize() {
    initCalls++;
    return _take(_initResults, fallback: 1);
  }

  int shutdown() {
    shutdownCalls++;
    return _take(_shutdownResults, fallback: 0);
  }

  void recordFinalizerError(Object error, StackTrace stackTrace) {
    finalizerErrors.add(error);
  }

  static int _take(List<int> results, {required int fallback}) =>
      results.isEmpty ? fallback : results.removeAt(0);
}
