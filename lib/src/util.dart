/// Compatibility import path for the managed runtime API.
///
/// The former eager `libgit2` and `libgit2Opts` globals were intentionally
/// removed. Import `runtime.dart` or the package barrel and use
/// `libgit2Runtime` instead.
library;

export 'runtime.dart';
