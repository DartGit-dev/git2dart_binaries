import 'dart:io';

import 'package:yaml/yaml.dart';

enum WorkflowConditionKind {
  always,
  pullRequest,
  mainPush,
  docsCommit,
  nonDocsCommit,
  cacheMiss,
}

final class WorkflowCondition {
  const WorkflowCondition(this.kind, this.source);

  final WorkflowConditionKind kind;
  final String source;

  bool evaluate({
    required String event,
    required String ref,
    String commitMessage = '',
  }) => switch (kind) {
    WorkflowConditionKind.always => true,
    WorkflowConditionKind.pullRequest => event == 'pull_request',
    WorkflowConditionKind.mainPush =>
      event == 'push' && ref == 'refs/heads/main',
    WorkflowConditionKind.docsCommit =>
      event == 'push' && commitMessage.contains('[docs]'),
    WorkflowConditionKind.nonDocsCommit => !commitMessage.contains('[docs]'),
    WorkflowConditionKind.cacheMiss => false,
  };

  static WorkflowCondition parse(Object? value) {
    if (value == null) {
      return const WorkflowCondition(WorkflowConditionKind.always, 'always');
    }
    final source = value.toString().trim();
    final normalized =
        source
            .replaceFirst(RegExp(r'^\$\{\{\s*'), '')
            .replaceFirst(RegExp(r'\s*\}\}$'), '')
            .trim();
    if (normalized == "github.event_name == 'pull_request'") {
      return WorkflowCondition(WorkflowConditionKind.pullRequest, normalized);
    }
    if (normalized ==
        "github.event_name == 'push' && github.ref == 'refs/heads/main'") {
      return WorkflowCondition(WorkflowConditionKind.mainPush, normalized);
    }
    if (normalized == "contains(github.event.head_commit.message, '[docs]')") {
      return WorkflowCondition(WorkflowConditionKind.docsCommit, normalized);
    }
    if (normalized == "!contains(github.event.head_commit.message, '[docs]')") {
      return WorkflowCondition(WorkflowConditionKind.nonDocsCommit, normalized);
    }
    if (RegExp(
      r"^steps\.[A-Za-z0-9_-]+\.outputs\.cache-hit != 'true'$",
    ).hasMatch(normalized)) {
      return WorkflowCondition(WorkflowConditionKind.cacheMiss, normalized);
    }
    throw FormatException('unsupported workflow condition: $source');
  }
}

final class WorkflowStepFact {
  const WorkflowStepFact({
    required this.name,
    required this.uses,
    required this.run,
    required this.condition,
    required this.withValues,
  });

  final String name;
  final String? uses;
  final String? run;
  final WorkflowCondition condition;
  final Map<String, Object?> withValues;
}

final class WorkflowJobFact {
  const WorkflowJobFact({
    required this.id,
    required this.needs,
    required this.condition,
    required this.steps,
  });

  final String id;
  final Set<String> needs;
  final WorkflowCondition condition;
  final List<WorkflowStepFact> steps;

  WorkflowStepFact step(String name) => steps.singleWhere(
    (step) => step.name == name,
    orElse: () => throw StateError('workflow step missing: $id/$name'),
  );

  int stepIndex(String name) => steps.indexWhere((step) => step.name == name);
}

final class WorkflowPolicyFacts {
  const WorkflowPolicyFacts({required this.events, required this.jobs});

  factory WorkflowPolicyFacts.fromFile(String path) {
    final document = parseYamlFile(path);
    final events = _stringMap(document['on'], context: 'on');
    final rawJobs = _stringMap(document['jobs'], context: 'jobs');
    final jobs = <String, WorkflowJobFact>{};
    for (final entry in rawJobs.entries) {
      final job = _stringMap(entry.value, context: 'job ${entry.key}');
      final needs = switch (job['needs']) {
        null => <String>{},
        final String value => <String>{value},
        final List<Object?> values =>
          values.map((value) => value.toString()).toSet(),
        _ => throw FormatException('unsupported needs for ${entry.key}'),
      };
      final rawSteps = job['steps'];
      if (rawSteps is! List<Object?>) {
        throw FormatException('steps missing for ${entry.key}');
      }
      final steps = <WorkflowStepFact>[];
      for (var stepIndex = 0; stepIndex < rawSteps.length; stepIndex++) {
        final rawStep = rawSteps[stepIndex];
        final step = _stringMap(rawStep, context: 'step in ${entry.key}');
        final declaredName = step['name'];
        final name =
            declaredName is String && declaredName.isNotEmpty
                ? declaredName
                : '${entry.key}#${stepIndex + 1}';
        steps.add(
          WorkflowStepFact(
            name: name,
            uses: step['uses']?.toString(),
            run: step['run']?.toString(),
            condition: WorkflowCondition.parse(step['if']),
            withValues:
                step['with'] == null
                    ? const <String, Object?>{}
                    : _stringMap(step['with'], context: 'with in $name'),
          ),
        );
      }
      jobs[entry.key] = WorkflowJobFact(
        id: entry.key,
        needs: needs,
        condition: WorkflowCondition.parse(job['if']),
        steps: steps,
      );
    }
    for (final job in jobs.values) {
      final missing = job.needs.difference(jobs.keys.toSet());
      if (missing.isNotEmpty) {
        throw FormatException('unknown needs for ${job.id}: $missing');
      }
    }
    return WorkflowPolicyFacts(events: events, jobs: jobs);
  }

  final Map<String, Object?> events;
  final Map<String, WorkflowJobFact> jobs;

  bool eventAccepted({required String event, required String ref}) {
    final config = events[event];
    if (config == null) return false;
    final branches = _stringMap(config, context: 'event $event')['branches'];
    final branch =
        ref.startsWith('refs/heads/')
            ? ref.substring('refs/heads/'.length)
            : ref;
    if (branches is! List<Object?>) {
      throw FormatException('unsupported branches for $event');
    }
    final values = branches.map((value) => value.toString()).toSet();
    return values.contains('**') || values.contains(branch);
  }

  bool validationReachable({
    required String event,
    required String ref,
    String commitMessage = '',
  }) {
    if (!_jobReachable(
      'publish_package',
      event: event,
      ref: ref,
      commitMessage: commitMessage,
      visiting: <String>{},
    ))
      return false;
    final publish = jobs['publish_package'];
    if (publish == null) return false;
    return publish.stepIndex('Validate publish package') >= 0;
  }

  bool publicationReachable({
    required String event,
    required String ref,
    String commitMessage = '',
  }) {
    if (!validationReachable(
      event: event,
      ref: ref,
      commitMessage: commitMessage,
    ))
      return false;
    final publishStep = jobs['publish_package']!.step('Publish package');
    return publishStep.condition.evaluate(
      event: event,
      ref: ref,
      commitMessage: commitMessage,
    );
  }

  bool _jobReachable(
    String jobId, {
    required String event,
    required String ref,
    required String commitMessage,
    required Set<String> visiting,
  }) {
    if (!eventAccepted(event: event, ref: ref) || !visiting.add(jobId)) {
      return false;
    }
    final job = jobs[jobId];
    if (job == null ||
        !job.condition.evaluate(
          event: event,
          ref: ref,
          commitMessage: commitMessage,
        )) {
      visiting.remove(jobId);
      return false;
    }
    final reachable = job.needs.every(
      (dependency) => _jobReachable(
        dependency,
        event: event,
        ref: ref,
        commitMessage: commitMessage,
        visiting: visiting,
      ),
    );
    visiting.remove(jobId);
    return reachable;
  }
}

Map<String, Object?> parseYamlFile(String path) {
  final document = loadYaml(File(path).readAsStringSync());
  return _stringMap(_toDart(document), context: path);
}

Set<String> githubHashFileInputs(Object? scalar) {
  final source = scalar?.toString() ?? '';
  final inputs = <String>{};
  for (final call in RegExp(r'hashFiles\(([^)]*)\)').allMatches(source)) {
    for (final literal in RegExp(
      '''['"]([^'"]+)['"]''',
    ).allMatches(call.group(1)!)) {
      inputs.add(literal.group(1)!);
    }
  }
  return inputs;
}

Set<String> githubInputReferences(Object? scalar) =>
    RegExp(r'inputs\.([A-Za-z0-9_-]+)')
        .allMatches(scalar?.toString() ?? '')
        .map((match) => match.group(1)!)
        .toSet();

Object? _toDart(Object? value) {
  if (value is YamlMap) {
    return <String, Object?>{
      for (final entry in value.entries)
        entry.key.toString(): _toDart(entry.value),
    };
  }
  if (value is YamlList) return value.map(_toDart).toList();
  return value;
}

Map<String, Object?> _stringMap(Object? value, {required String context}) {
  if (value is Map<String, Object?>) return value;
  throw FormatException('expected mapping at $context');
}

void main() {
  try {
    final facts = WorkflowPolicyFacts.fromFile(
      '.github/workflows/build_package.yml',
    );
    stdout.writeln(
      'workflow-policy: ${facts.jobs.length} jobs; '
      'main-publish=${facts.publicationReachable(event: 'push', ref: 'refs/heads/main')}',
    );
  } catch (error) {
    stderr.writeln('workflow-policy-failed: $error');
    exitCode = 1;
  }
}
