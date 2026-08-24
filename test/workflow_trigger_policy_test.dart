import 'dart:io';

import 'package:test/test.dart';

void main() {
  final workflow = File('.github/workflows/build_package.yml')
      .readAsStringSync()
      .replaceAll('\r\n', '\n');

  test('validates pushes from every branch while retaining main pull requests', () {
    expect(workflow, contains("branches: ['**']"));
    expect(workflow, contains('pull_request:\n    branches:\n      - "main"'));
  });

  test('keeps package validation available while guarding only publication', () {
    expect(
      workflow,
      isNot(
        contains(
          """  publish_package:
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'""",
        ),
      ),
    );
    expect(workflow, contains('  publish_package:\n    needs:'));
    expect(workflow, contains('Validate publish package'));
    expect(
      workflow,
      contains("""      - name: Zip package into cache
        if: \${{ github.event_name == 'pull_request' }}"""),
    );
    expect(
      workflow,
      contains("""      - name: Publish package
        if: github.event_name == 'push' && github.ref == 'refs/heads/main'"""),
    );
  });
}
