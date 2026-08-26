import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../tool/package_consumer_bundle.dart';
import 'support/behavior_proof_fixture.dart';

void main() {
  late BehaviorProofFixture fixture;
  late Directory fixturePackage;

  setUp(() async {
    fixture = await BehaviorProofFixture.create('consumer-bundle-test-');
    fixturePackage = Directory(
      Platform.environment['GIT2DART_FIXTURE_PACKAGE_ROOT'] ??
          'C:/Users/Viktor/AppData/Local/Pub/Cache/hosted/pub.dev/git2dart_binaries-1.12.1',
    );
  });
  tearDown(() => fixture.dispose());

  test('assembler rejects checkout bindings and undeclared payload origin', () {
    final checkoutBinding = File('lib/src/bindings.dart');
    if (checkoutBinding.existsSync()) {
      expect(
        () => assembleConsumerBundle(
          sourceRoot: Directory.current,
          bindingFile: checkoutBinding,
          payloadRoot: Directory(p.join(fixturePackage.path, _platform())),
          bundleRoot: Directory(p.join(fixture.root.path, 'checkout-bundle')),
          platform: _platform(),
        ),
        throwsStateError,
      );
    }
    expect(
      () => assembleConsumerBundle(
        sourceRoot: Directory.current,
        bindingFile: File(p.join(fixturePackage.path, 'lib/src/bindings.dart')),
        payloadRoot: Directory(p.join(fixturePackage.path, _platform())),
        bundleRoot: Directory(p.join(fixture.root.path, 'cache-bundle')),
        platform: _platform(),
        bindingOrigin: 'global-cache',
      ),
      throwsStateError,
    );
  });

  test(
    'clean consumer compiles public imports and rejects internal imports',
    () async {
      if (!_fixtureAvailable(fixturePackage)) {
        stdout.writeln(
          'consumer-evidence: unavailable (no declared fixture package)',
        );
        return;
      }
      final bundle = Directory(p.join(fixture.root.path, 'bundle'));
      final evidence = assembleConsumerBundle(
        sourceRoot: Directory.current,
        bindingFile: File(p.join(fixturePackage.path, 'lib/src/bindings.dart')),
        payloadRoot: Directory(p.join(fixturePackage.path, _platform())),
        bundleRoot: bundle,
        platform: _platform(),
      );
      expect(evidence.bindingOrigin, 'same-run');
      expect(evidence.payloadFiles, isNotEmpty);

      final publicResult = await runCleanConsumer(
        bundleRoot: bundle,
        mode: 'compile-public-api',
      );
      expect(
        publicResult.succeeded,
        isTrue,
        reason:
            '${publicResult.category}\n${publicResult.stdout}\n${publicResult.stderr}',
      );
      expect(publicResult.stdout, contains('public-api-ok'));

      final internalResult = await runCleanConsumer(
        bundleRoot: bundle,
        mode: 'compile-public-api',
        imports: const <String>['package:git2dart_binaries/src/runtime.dart'],
      );
      expect(internalResult.exitCode, isNot(0));
      expect(internalResult.category, 'internal-import');
    },
  );

  test('clean native consumer loads only from the assembled bundle', () async {
    if (!_fixtureAvailable(fixturePackage)) {
      stdout.writeln('consumer-native-evidence: unavailable');
      return;
    }
    final bundle = Directory(p.join(fixture.root.path, 'native-bundle'));
    assembleConsumerBundle(
      sourceRoot: Directory.current,
      bindingFile: File(p.join(fixturePackage.path, 'lib/src/bindings.dart')),
      payloadRoot: Directory(p.join(fixturePackage.path, _platform())),
      bundleRoot: bundle,
      platform: _platform(),
    );
    final result = await runCleanConsumer(
      bundleRoot: bundle,
      mode: 'load-native',
    );
    expect(
      result.succeeded,
      isTrue,
      reason: '${result.category}\n${result.stdout}\n${result.stderr}',
    );
    expect(result.stdout, contains('load-native-ok'));
  });

  test('bundled ABI and isolated loader probes execute', () async {
    if (!_fixtureAvailable(fixturePackage)) {
      stdout.writeln('abi-loader-evidence: unavailable');
      return;
    }
    final bundle = Directory(p.join(fixture.root.path, 'probe-bundle'));
    assembleConsumerBundle(
      sourceRoot: Directory.current,
      bindingFile: File(p.join(fixturePackage.path, 'lib/src/bindings.dart')),
      payloadRoot: Directory(p.join(fixturePackage.path, _platform())),
      bundleRoot: bundle,
      platform: _platform(),
    );
    final abi = await runCleanConsumer(bundleRoot: bundle, mode: 'abi-probe');
    expect(
      abi.succeeded,
      isTrue,
      reason: '${abi.category}\n${abi.stdout}\n${abi.stderr}',
    );
    expect(
      abi.stdout,
      anyOf(contains('abi-probe-ok'), contains('abi-probe-unavailable')),
    );

    final loader = await runCleanConsumer(
      bundleRoot: bundle,
      mode: 'loader-probe',
    );
    expect(
      loader.succeeded,
      isTrue,
      reason: '${loader.stdout}\n${loader.stderr}',
    );
    expect(loader.stdout, contains('loader-probe-ok'));

    final missingRoot = Directory(p.join(fixture.root.path, 'missing-payload'))
      ..createSync();
    final missing = await runCleanConsumer(
      bundleRoot: bundle,
      mode: 'loader-probe',
      packageRootOverride: missingRoot,
    );
    expect(missing.exitCode, isNot(0));
    expect(missing.category, 'loader-failed');
    expect(missing.stderr, contains('Failed to open libgit2. Tried:'));
    expect(missing.stderr, contains('<payload-root>'));

    final android = await runCleanConsumer(
      bundleRoot: bundle,
      mode: 'android-plan',
    );
    expect(android.succeeded, isTrue, reason: android.stderr);
    expect(android.stdout, contains('android-no-fallback-ok'));
  });
}

String _platform() =>
    Platform.isWindows
        ? 'windows'
        : Platform.isMacOS
        ? 'macos'
        : 'linux';

bool _fixtureAvailable(Directory root) =>
    File(p.join(root.path, 'lib/src/bindings.dart')).existsSync() &&
    Directory(p.join(root.path, _platform())).existsSync();
