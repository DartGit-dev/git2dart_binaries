/// libgit2 binaries.
library git2dart_bindings;

import 'package:git2dart_binaries/src/bindings.dart';
import 'package:git2dart_binaries/src/util.dart';

export libgit2 = Libgit2(loadLibrary(getLibName()));

export 'src/bindings.dart';

