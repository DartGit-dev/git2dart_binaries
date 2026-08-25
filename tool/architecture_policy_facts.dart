import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:path/path.dart' as p;

const expectedAnalyzerVersion = '8.2.0';

final class AnalyzerResolution {
  const AnalyzerResolution(this.version, this.root);

  final String version;
  final String root;
}

AnalyzerResolution verifyAnalyzerResolution({
  String packageConfigPath = '.dart_tool/package_config.json',
}) {
  final configFile = File(packageConfigPath).absolute;
  if (!configFile.existsSync()) {
    throw StateError('analyzer-resolution: package config missing');
  }
  final decoded = jsonDecode(configFile.readAsStringSync());
  if (decoded is! Map<String, dynamic> || decoded['packages'] is! List) {
    throw StateError('analyzer-resolution: invalid package config');
  }
  Map<String, dynamic>? analyzer;
  for (final entry in decoded['packages'] as List) {
    if (entry is Map<String, dynamic> && entry['name'] == 'analyzer') {
      analyzer = entry;
      break;
    }
  }
  if (analyzer == null || analyzer['rootUri'] is! String) {
    throw StateError('analyzer-resolution: direct package missing');
  }
  final rootUri = configFile.uri.resolve(analyzer['rootUri'] as String);
  final root = Directory.fromUri(rootUri);
  final pubspec = File(p.join(root.path, 'pubspec.yaml'));
  if (!pubspec.existsSync()) {
    throw StateError('analyzer-resolution: package metadata missing');
  }
  final match = RegExp(
    r'^version:\s*([^\s]+)',
    multiLine: true,
  ).firstMatch(pubspec.readAsStringSync());
  final resolved = match?.group(1);
  if (resolved != expectedAnalyzerVersion) {
    throw StateError(
      'analyzer-resolution: expected $expectedAnalyzerVersion, resolved ${resolved ?? 'unknown'}',
    );
  }
  return AnalyzerResolution(resolved!, root.absolute.path);
}

final class ArchitectureFact {
  const ArchitectureFact({
    required this.file,
    required this.kind,
    required this.symbol,
    required this.allowed,
  });

  final String file;
  final String kind;
  final String symbol;
  final bool allowed;

  Map<String, Object> toJson() => <String, Object>{
    'file': file,
    'kind': kind,
    'symbol': symbol,
    'allowed': allowed,
  };
}

List<ArchitectureFact> collectArchitectureFacts({String root = 'lib'}) {
  verifyAnalyzerResolution();
  final rootDirectory = Directory(root).absolute;
  final facts = <ArchitectureFact>[];
  final files =
      rootDirectory
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .toList()
        ..sort((left, right) => left.path.compareTo(right.path));
  for (final file in files) {
    final relative = p
        .relative(file.path, from: Directory.current.absolute.path)
        .replaceAll(p.separator, '/');
    final parsed = parseFile(
      path: file.path,
      featureSet: FeatureSet.latestLanguageVersion(),
    );
    parsed.unit.accept(_ArchitectureVisitor(relative, facts));
  }
  return facts;
}

final class _ArchitectureVisitor extends RecursiveAstVisitor<void> {
  _ArchitectureVisitor(this.file, this.facts);

  final String file;
  final List<ArchitectureFact> facts;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (file == 'lib/src/runtime.dart') {
      facts.add(
        ArchitectureFact(
          file: file,
          kind: 'class',
          symbol: node.name.lexeme,
          allowed: true,
        ),
      );
    }
    super.visitClassDeclaration(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final name = node.methodName.name;
    if (name == 'git_libgit2_init' || name == 'git_libgit2_shutdown') {
      facts.add(
        ArchitectureFact(
          file: file,
          kind: 'native-lifecycle-transition',
          symbol: name,
          allowed: file == 'lib/src/runtime.dart',
        ),
      );
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    for (final variable in node.variables.variables) {
      final name = variable.name.lexeme;
      if (name == 'libgit2' || name == 'libgit2Opts') {
        facts.add(
          ArchitectureFact(
            file: file,
            kind: 'prohibited-lifecycle-global',
            symbol: name,
            allowed: false,
          ),
        );
      }
    }
    super.visitTopLevelVariableDeclaration(node);
  }
}

void main() {
  try {
    final resolution = verifyAnalyzerResolution();
    final facts = collectArchitectureFacts();
    final violations = facts.where((fact) => !fact.allowed).toList();
    stdout.writeln(
      jsonEncode(<String, Object>{
        'analyzer_version': resolution.version,
        'facts': facts.map((fact) => fact.toJson()).toList(),
        'violations': violations.map((fact) => fact.toJson()).toList(),
      }),
    );
    if (violations.isNotEmpty) exitCode = 1;
  } catch (error) {
    stderr.writeln('architecture-policy-failed: $error');
    exitCode = 1;
  }
}
