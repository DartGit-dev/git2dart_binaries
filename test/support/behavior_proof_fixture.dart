import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

final class BehaviorProofFixture {
  BehaviorProofFixture._(this.root);

  final Directory root;

  static Future<BehaviorProofFixture> create(String prefix) async =>
      BehaviorProofFixture._(await Directory.systemTemp.createTemp(prefix));

  File file(String relativePath) {
    final normalized = p.normalize(relativePath);
    if (p.isAbsolute(normalized) ||
        normalized == '..' ||
        normalized.startsWith('..${p.separator}')) {
      throw ArgumentError.value(relativePath, 'relativePath', 'unsafe path');
    }
    final result = File(p.join(root.path, normalized));
    result.parent.createSync(recursive: true);
    return result;
  }

  String sanitize(Object? value) =>
      value.toString().replaceAll(root.absolute.path, '<fixture-root>');

  Future<ProcessResult> runBounded(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final process = await Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory ?? root.path,
      environment: environment,
    );
    final stdoutFuture =
        process.stdout.transform(systemEncoding.decoder).join();
    final stderrFuture =
        process.stderr.transform(systemEncoding.decoder).join();
    try {
      final exitCode = await process.exitCode.timeout(timeout);
      return ProcessResult(
        process.pid,
        exitCode,
        sanitize(await stdoutFuture),
        sanitize(await stderrFuture),
      );
    } on TimeoutException {
      process.kill();
      await process.exitCode;
      throw TimeoutException('subprocess exceeded ${timeout.inSeconds}s');
    }
  }

  Future<void> dispose() async {
    if (root.existsSync()) await root.delete(recursive: true);
  }
}

String dartExecutable() {
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
