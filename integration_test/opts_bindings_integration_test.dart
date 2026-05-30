import 'package:integration_test/integration_test.dart';

import '../test/opts_bindings_integration_test.dart' as opts_bindings;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  opts_bindings.main();
}
