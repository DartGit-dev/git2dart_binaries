import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

const consumerEvidenceSchema = 'git2dart-consumer-bundle/v1';

final class BundleEvidence {
  const BundleEvidence({
    required this.bundleRoot,
    required this.platform,
    required this.bindingOrigin,
    required this.payloadFiles,
  });

  final Directory bundleRoot;
  final String platform;
  final String bindingOrigin;
  final List<String> payloadFiles;

  Map<String, Object> toJson() => <String, Object>{
    'schema': consumerEvidenceSchema,
    'bundle': '.',
    'platform': platform,
    'binding_origin': bindingOrigin,
    'payload_files': payloadFiles,
  };
}

BundleEvidence assembleConsumerBundle({
  required Directory sourceRoot,
  required File bindingFile,
  required Directory payloadRoot,
  required Directory bundleRoot,
  required String platform,
  String bindingOrigin = 'same-run',
}) {
  if (bindingOrigin != 'same-run') {
    throw StateError('bundle-invalid: binding origin must be same-run');
  }
  if (!bindingFile.existsSync()) {
    throw StateError('binding-missing');
  }
  if (_isInside(bindingFile.absolute.path, sourceRoot.absolute.path)) {
    throw StateError('bundle-invalid: checkout binding fallback rejected');
  }
  if (!payloadRoot.existsSync()) throw StateError('payload-missing');
  final requiredPayload = _requiredPayload(platform);
  final names =
      payloadRoot
          .listSync(recursive: true)
          .whereType<File>()
          .map((file) => p.basename(file.path).toLowerCase())
          .toList();
  for (final requirement in requiredPayload) {
    if (!names.any(requirement)) throw StateError('payload-missing');
  }

  if (bundleRoot.existsSync()) {
    if (bundleRoot.listSync().isNotEmpty) {
      throw StateError('bundle-invalid: output root is not empty');
    }
  } else {
    bundleRoot.createSync(recursive: true);
  }
  for (final fileName in <String>[
    'pubspec.yaml',
    'analysis_options.yaml',
    'LICENSE',
    'README.md',
  ]) {
    final source = File(p.join(sourceRoot.path, fileName));
    if (source.existsSync()) _copyFile(source, bundleRoot, fileName);
  }
  for (final directoryName in <String>[
    'lib',
    'assets',
    'android',
    'ios',
    'linux',
    'macos',
    'windows',
  ]) {
    final source = Directory(p.join(sourceRoot.path, directoryName));
    if (!source.existsSync()) continue;
    _copyTree(
      source,
      Directory(p.join(bundleRoot.path, directoryName)),
      exclude:
          (relative) =>
              directoryName == 'lib' &&
              relative.replaceAll(r'\', '/') == 'src/bindings.dart',
    );
  }
  _copyFile(bindingFile, bundleRoot, 'lib/src/bindings.dart');
  final payloadDestination = Directory(p.join(bundleRoot.path, platform));
  _copyTree(payloadRoot, payloadDestination);
  final payloadFiles =
      payloadDestination
          .listSync(recursive: true)
          .whereType<File>()
          .map(
            (file) => p
                .relative(file.path, from: bundleRoot.path)
                .replaceAll(p.separator, '/'),
          )
          .toList()
        ..sort();
  final evidence = BundleEvidence(
    bundleRoot: bundleRoot,
    platform: platform,
    bindingOrigin: bindingOrigin,
    payloadFiles: payloadFiles,
  );
  File(p.join(bundleRoot.path, 'bundle-proof.json')).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(evidence.toJson())}\n',
  );
  return evidence;
}

final class ConsumerRunResult {
  const ConsumerRunResult({
    required this.exitCode,
    required this.category,
    required this.stdout,
    required this.stderr,
  });

  final int exitCode;
  final String category;
  final String stdout;
  final String stderr;

  bool get succeeded => exitCode == 0;
}

Future<ConsumerRunResult> runCleanConsumer({
  required Directory bundleRoot,
  required String mode,
  List<String> imports = const <String>[
    'package:git2dart_binaries/git2dart_binaries.dart',
  ],
  Directory? packageRootOverride,
  Duration timeout = const Duration(seconds: 90),
}) async {
  if (!File(p.join(bundleRoot.path, 'bundle-proof.json')).existsSync()) {
    return const ConsumerRunResult(
      exitCode: 1,
      category: 'bundle-invalid',
      stdout: '',
      stderr: 'bundle evidence missing',
    );
  }
  if (imports.any((value) => value.contains('/src/'))) {
    return const ConsumerRunResult(
      exitCode: 1,
      category: 'internal-import',
      stdout: '',
      stderr: 'internal package imports are not consumer evidence',
    );
  }
  const modes = <String>{
    'compile-public-api',
    'load-native',
    'abi-probe',
    'loader-probe',
    'android-plan',
  };
  if (!modes.contains(mode)) {
    throw ArgumentError.value(mode, 'mode');
  }
  final consumer = await Directory.systemTemp.createTemp('git2dart-consumer-');
  try {
    File(p.join(consumer.path, 'pubspec.yaml')).writeAsStringSync('''
name: git2dart_bundle_consumer
publish_to: none
environment:
  sdk: ">=3.7.2 <4.0.0"
dependencies:
  ffi: ^2.0.0
  git2dart_binaries:
    path: ${bundleRoot.absolute.path.replaceAll(r'\', '/')}
dev_dependencies:
  flutter_test:
    sdk: flutter
''');
    final plainDart = mode == 'loader-probe' || mode == 'android-plan';
    final scriptDirectory = Directory(
      p.join(consumer.path, plainDart ? 'bin' : 'test'),
    )..createSync();
    final script = File(
      p.join(
        scriptDirectory.path,
        plainDart ? 'main.dart' : 'consumer_test.dart',
      ),
    );
    script.writeAsStringSync(_consumerSource(mode, imports));

    final get = await _run(
      _flutterExecutable(),
      const <String>['pub', 'get', '--offline'],
      workingDirectory: consumer.path,
      timeout: timeout,
    );
    if (get.exitCode != 0) {
      return ConsumerRunResult(
        exitCode: get.exitCode,
        category: 'bundle-invalid',
        stdout: _sanitize(get.stdout, consumer, bundleRoot),
        stderr: _sanitize(get.stderr, consumer, bundleRoot),
      );
    }
    final packageConfig = File(
      p.join(consumer.path, '.dart_tool/package_config.json'),
    );
    final decoded =
        jsonDecode(packageConfig.readAsStringSync()) as Map<String, dynamic>;
    final packages = decoded['packages'] as List;
    final package = packages.cast<Map<String, dynamic>>().singleWhere(
      (entry) => entry['name'] == 'git2dart_binaries',
    );
    final resolved = packageConfig.uri.resolve(package['rootUri'] as String);
    if (Directory.fromUri(resolved).absolute.path != bundleRoot.absolute.path) {
      return const ConsumerRunResult(
        exitCode: 1,
        category: 'bundle-invalid',
        stdout: '',
        stderr: 'consumer resolved a non-bundle package root',
      );
    }
    final run = await _run(
      plainDart ? _dartExecutable() : _flutterExecutable(),
      plainDart
          ? <String>[script.path]
          : <String>['test', '-j', '1', script.path],
      workingDirectory: consumer.path,
      environment: <String, String>{
        'GIT2DART_BINARIES_PACKAGE_ROOT':
            (packageRootOverride ?? bundleRoot).absolute.path,
      },
      timeout: timeout,
    );
    return ConsumerRunResult(
      exitCode: run.exitCode,
      category:
          run.exitCode == 0
              ? 'passed'
              : mode == 'load-native' || mode == 'loader-probe'
              ? 'loader-failed'
              : 'bundle-invalid',
      stdout: _sanitize(run.stdout, consumer, bundleRoot, packageRootOverride),
      stderr: _sanitize(run.stderr, consumer, bundleRoot, packageRootOverride),
    );
  } on TimeoutException {
    return const ConsumerRunResult(
      exitCode: 1,
      category: 'timeout',
      stdout: '',
      stderr: 'consumer subprocess timed out',
    );
  } finally {
    if (consumer.existsSync()) await consumer.delete(recursive: true);
  }
}

String _consumerSource(String mode, List<String> imports) {
  final importLines = imports.map((value) => "import '$value';").join('\n');
  if (mode == 'compile-public-api') {
    return '''
$importLines
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('public API compiles and executes', () {
    final state = Libgit2RuntimeState.forTesting(
      initialize: () => 1,
      shutdown: () => 0,
    );
    state.ensureInitialized();
    expect(state.isInitialized, isTrue);
    expect(state.shutdown(), 0);
    print('public-api-ok');
  });
}
''';
  }
  if (mode == 'abi-probe') {
    return '''
$importLines
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('native size value crosses the ABI exactly', () {
    if (ffi.sizeOf<ffi.IntPtr>() != 8) {
      print('abi-probe-unavailable');
      return;
    }
    const submitted = 0x100000011;
    final value = calloc<ffi.Size>();
    final originalResult = libgit2Runtime.options
        .git_libgit2_opts_get_mwindow_file_limit(value);
    expect(originalResult, 0);
    final original = value.value;
    addTearDown(() {
      libgit2Runtime.options.git_libgit2_opts_set_mwindow_file_limit(original);
      calloc.free(value);
      libgit2Runtime.shutdown();
    });
    expect(
      libgit2Runtime.options.git_libgit2_opts_set_mwindow_file_limit(submitted),
      0,
    );
    expect(
      libgit2Runtime.options.git_libgit2_opts_get_mwindow_file_limit(value),
      0,
    );
    expect(value.value, submitted);
    print('abi-probe-ok');
  });
}
''';
  }
  if (mode == 'loader-probe') {
    return '''
import 'package:git2dart_binaries/src/runtime.dart';

void main() {
  libgit2Runtime.ensureInitialized();
  print('loader-probe-ok');
  libgit2Runtime.shutdown();
}
''';
  }
  if (mode == 'android-plan') {
    return '''
import 'package:git2dart_binaries/src/runtime.dart';

void main() {
  final plan = nativeLoaderPlanForTesting('android');
  if (plan.hasPackageFallback) throw StateError('Android fallback regression');
  print('android-no-fallback-ok');
}
''';
  }
  return '''
$importLines
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bundled native payload loads', () {
    libgit2Runtime.ensureInitialized();
    print('load-native-ok');
    expect(libgit2Runtime.shutdown(), greaterThanOrEqualTo(0));
  });
}
''';
}

List<bool Function(String)> _requiredPayload(String platform) =>
    switch (platform) {
      'windows' => <bool Function(String)>[
        (name) => name == 'libgit2.dll',
        (name) => name == 'libssh2.dll',
        (name) => name.startsWith('libcrypto') && name.endsWith('.dll'),
        (name) => name.startsWith('libssl') && name.endsWith('.dll'),
      ],
      'linux' => <bool Function(String)>[
        (name) => name == 'libgit2.so',
        (name) => name == 'libssh2.so',
      ],
      'macos' => <bool Function(String)>[(name) => name == 'libgit2.dylib'],
      _ => throw UnsupportedError('unsupported consumer platform: $platform'),
    };

void _copyTree(
  Directory source,
  Directory destination, {
  bool Function(String relative)? exclude,
}) {
  for (final entity in source.listSync(recursive: true)) {
    if (entity is! File) continue;
    final relative = p.relative(entity.path, from: source.path);
    if (exclude?.call(relative) ?? false) continue;
    _copyFile(entity, destination, relative);
  }
}

void _copyFile(File source, Directory root, String relative) {
  if (p.isAbsolute(relative) ||
      relative.split(RegExp(r'[/\\]')).contains('..')) {
    throw StateError('bundle-invalid: unsafe relative path');
  }
  final destination = File(p.join(root.path, relative));
  destination.parent.createSync(recursive: true);
  source.copySync(destination.path);
}

bool _isInside(String child, String parent) {
  final relative = p.relative(child, from: parent);
  return relative != '..' &&
      !relative.startsWith('..${p.separator}') &&
      !p.isAbsolute(relative);
}

String _sanitize(
  String value,
  Directory consumer,
  Directory bundle, [
  Directory? override,
]) {
  var sanitized = value
      .replaceAll(consumer.absolute.path, '<consumer-root>')
      .replaceAll(bundle.absolute.path, '<bundle-root>');
  if (override != null) {
    sanitized = sanitized.replaceAll(override.absolute.path, '<payload-root>');
  }
  return sanitized;
}

Future<({int exitCode, String stdout, String stderr})> _run(
  String executable,
  List<String> arguments, {
  required String workingDirectory,
  Map<String, String>? environment,
  required Duration timeout,
}) async {
  final process = await Process.start(
    executable,
    arguments,
    workingDirectory: workingDirectory,
    environment: environment,
    runInShell: Platform.isWindows && executable.toLowerCase().endsWith('.bat'),
  );
  final stdout = process.stdout.transform(systemEncoding.decoder).join();
  final stderr = process.stderr.transform(systemEncoding.decoder).join();
  try {
    final exitCode = await process.exitCode.timeout(timeout);
    return (exitCode: exitCode, stdout: await stdout, stderr: await stderr);
  } on TimeoutException {
    process.kill();
    await process.exitCode;
    rethrow;
  }
}

String _dartExecutable() {
  final resolved = File(Platform.resolvedExecutable).absolute;
  if (p.basenameWithoutExtension(resolved.path) == 'dart') return resolved.path;
  var directory = resolved.parent;
  while (directory.parent.path != directory.path) {
    final candidate = File(
      p.join(
        directory.path,
        'dart-sdk',
        'bin',
        Platform.isWindows ? 'dart.exe' : 'dart',
      ),
    );
    if (candidate.existsSync()) return candidate.path;
    directory = directory.parent;
  }
  return 'dart';
}

String _flutterExecutable() {
  var directory = File(_dartExecutable()).absolute.parent;
  while (directory.parent.path != directory.path) {
    final candidate = File(
      p.join(directory.path, Platform.isWindows ? 'flutter.bat' : 'flutter'),
    );
    if (candidate.existsSync()) return candidate.path;
    directory = directory.parent;
  }
  return Platform.isWindows ? 'flutter.bat' : 'flutter';
}

Future<void> main(List<String> arguments) async {
  if (arguments.contains('--help') || arguments.isEmpty) {
    stdout.writeln(
      'assemble --source DIR --binding FILE --payload DIR --platform NAME --output DIR\n'
      'run --bundle DIR --mode compile-public-api|load-native|abi-probe|loader-probe|android-plan',
    );
    return;
  }
  try {
    final command = arguments.first;
    final options = _options(arguments.skip(1).toList());
    if (command == 'assemble') {
      final evidence = assembleConsumerBundle(
        sourceRoot: Directory(_required(options, '--source')),
        bindingFile: File(_required(options, '--binding')),
        payloadRoot: Directory(_required(options, '--payload')),
        bundleRoot: Directory(_required(options, '--output')),
        platform: _required(options, '--platform'),
      );
      stdout.writeln(jsonEncode(evidence.toJson()));
      return;
    }
    if (command == 'run') {
      final result = await runCleanConsumer(
        bundleRoot: Directory(_required(options, '--bundle')),
        mode: _required(options, '--mode'),
      );
      stdout.writeln(
        jsonEncode(<String, Object>{
          'schema': consumerEvidenceSchema,
          'category': result.category,
          'stdout': result.stdout,
          'stderr': result.stderr,
        }),
      );
      if (!result.succeeded) exitCode = result.exitCode;
      return;
    }
    throw FormatException('unsupported command: $command');
  } catch (error) {
    stderr.writeln('bundle-invalid: $error');
    exitCode = 64;
  }
}

Map<String, String> _options(List<String> arguments) {
  if (arguments.length.isOdd) {
    throw const FormatException('option value missing');
  }
  final result = <String, String>{};
  for (var index = 0; index < arguments.length; index += 2) {
    final key = arguments[index];
    if (!key.startsWith('--') || result.containsKey(key)) {
      throw FormatException('invalid option: $key');
    }
    result[key] = arguments[index + 1];
  }
  return result;
}

String _required(Map<String, String> options, String key) {
  final value = options[key];
  if (value == null || value.isEmpty) throw FormatException('missing $key');
  return value;
}
