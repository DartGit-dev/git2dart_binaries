import 'dart:ffi' as ffi;
import 'package:git2dart_binaries/src/bindings.dart';

/// Bindings to libgit2 global options.
///
/// This class provides access to various global configuration options in libgit2.
/// It allows you to configure memory usage, caching behavior, SSL certificates,
/// and other global settings that affect how libgit2 operates.
class Libgit2Opts {
  /// Holds the symbol lookup function for FFI bindings.
  ///
  /// This function is used to look up native symbols in the dynamic library.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
  _lookup;

  /// Creates a new instance of [Libgit2Opts].
  ///
  /// The [dynamicLibrary] parameter is used to look up the native symbols.
  Libgit2Opts(ffi.DynamicLibrary dynamicLibrary)
    : _lookup = dynamicLibrary.lookup;

  /// Gets the maximum mmap window size.
  ///
  /// The mmap window size determines how much memory can be mapped at once
  /// when reading pack files. The result is stored in [out].
  ///
  /// Returns 0 on success, or a negative error code.
  int git_libgit2_opts_get_mwindow_size(ffi.Pointer<ffi.Int> out) {
    return _git_libgit2_opts_get_int(
      git_libgit2_opt_t.GIT_OPT_GET_MWINDOW_SIZE.value,
      out,
    );
  }

  /// Sets the maximum mmap window size.
  ///
  /// The [value] parameter specifies the new maximum mmap window size in bytes.
  /// This affects how much memory can be mapped at once when reading pack files.
  ///
  /// Returns 0 on success, or a negative error code.
  int git_libgit2_opts_set_mwindow_size(int value) {
    return _git_libgit2_opts_set_int(
      git_libgit2_opt_t.GIT_OPT_SET_MWINDOW_SIZE.value,
      value,
    );
  }

  /// Gets the maximum memory that will be mapped in total by the library.
  ///
  /// The result is stored in [out]. A value of 0 means unlimited.
  ///
  /// Returns 0 on success, or a negative error code.
  int git_libgit2_opts_get_mwindow_mapped_limit(ffi.Pointer<ffi.Int> out) {
    return _git_libgit2_opts_get_int(
      git_libgit2_opt_t.GIT_OPT_GET_MWINDOW_MAPPED_LIMIT.value,
      out,
    );
  }

  /// Sets the maximum amount of memory that can be mapped at any time.
  ///
  /// The [value] parameter specifies the new limit in bytes. Set to 0 for unlimited.
  ///
  /// Returns 0 on success, or a negative error code.
  int git_libgit2_opts_set_mwindow_mapped_limit(int value) {
    return _git_libgit2_opts_set_int(
      git_libgit2_opt_t.GIT_OPT_SET_MWINDOW_MAPPED_LIMIT.value,
      value,
    );
  }

  /// Gets the maximum number of files that will be mapped at any time.
  ///
  /// The result is stored in [out]. A value of 0 means unlimited.
  ///
  /// Returns 0 on success, or a negative error code.
  int git_libgit2_opts_get_mwindow_file_limit(ffi.Pointer<ffi.Int> out) {
    return _git_libgit2_opts_get_int(
      git_libgit2_opt_t.GIT_OPT_GET_MWINDOW_FILE_LIMIT.value,
      out,
    );
  }

  /// Sets the maximum number of files that can be mapped at any time.
  ///
  /// The [value] parameter specifies the new limit. Set to 0 for unlimited.
  ///
  /// Returns 0 on success, or a negative error code.
  int git_libgit2_opts_set_mwindow_file_limit(int value) {
    return _git_libgit2_opts_set_int(
      git_libgit2_opt_t.GIT_OPT_SET_MWINDOW_FILE_LIMIT.value,
      value,
    );
  }

  /// Gets the search path for a given level of config data.
  ///
  /// The [level] parameter must be one of:
  /// * `GIT_CONFIG_LEVEL_SYSTEM`
  /// * `GIT_CONFIG_LEVEL_GLOBAL`
  /// * `GIT_CONFIG_LEVEL_XDG`
  /// * `GIT_CONFIG_LEVEL_PROGRAMDATA`
  ///
  /// The search path is written to the [out] buffer.
  ///
  /// Returns 0 on success, or a negative error code.
  int git_libgit2_opts_get_search_path(int level, ffi.Pointer<git_buf> out) {
    return _git_libgit2_opts_get_search_path(
      git_libgit2_opt_t.GIT_OPT_GET_SEARCH_PATH.value,
      level,
      out,
    );
  }

  /// Sets the search path for a level of config data.
  ///
  /// The search path is also applied to shared attributes and ignore files.
  ///
  /// The [path] parameter lists directories delimited by GIT_PATH_LIST_SEPARATOR.
  /// Pass NULL to reset to the default (based on environment variables).
  /// Use magic path `$PATH` to include the old value of the path.
  ///
  /// The [level] parameter must be one of:
  /// * `GIT_CONFIG_LEVEL_SYSTEM`
  /// * `GIT_CONFIG_LEVEL_GLOBAL`
  /// * `GIT_CONFIG_LEVEL_XDG`
  /// * `GIT_CONFIG_LEVEL_PROGRAMDATA`
  ///
  /// Returns 0 on success, or a negative error code.
  int git_libgit2_opts_set_search_path(int level, ffi.Pointer<ffi.Char> path) {
    return _git_libgit2_opts_set_search_path(
      git_libgit2_opt_t.GIT_OPT_SET_SEARCH_PATH.value,
      level,
      path,
    );
  }

  /// Sets the maximum data size for caching objects of a given type.
  ///
  /// The [type] parameter specifies the type of object (e.g., GIT_OBJECT_BLOB).
  /// The [value] parameter specifies the maximum size in bytes.
  /// Setting [value] to 0 means that type of object will not be cached.
  ///
  /// Defaults:
  /// * 0 for GIT_OBJECT_BLOB (won't cache blobs)
  /// * 4k for GIT_OBJECT_COMMIT, GIT_OBJECT_TREE, and GIT_OBJECT_TAG
  ///
  /// Returns 0 on success, or a negative error code.
  int git_libgit2_opts_set_cache_object_limit(int type, int value) {
    return _git_libgit2_opts_set_cache_object_limit(
      git_libgit2_opt_t.GIT_OPT_SET_CACHE_OBJECT_LIMIT.value,
      type,
      value,
    );
  }

  /// Sets the maximum total data size for the object cache.
  ///
  /// The [bytes] parameter specifies the new limit in bytes.
  /// This is a soft limit - the library might briefly exceed it,
  /// but will start aggressively evicting objects when that happens.
  ///
  /// The default cache size is 256MB.
  ///
  /// Returns 0 on success, or a negative error code.
  int git_libgit2_opts_set_cache_max_size(int bytes) {
    return _git_libgit2_opts_set_int(
      git_libgit2_opt_t.GIT_OPT_SET_CACHE_MAX_SIZE.value,
      bytes,
    );
  }

  /// Gets the current cache memory usage and maximum allowed.
  ///
  /// The current usage is stored in [current].
  /// The maximum allowed is stored in [allowed].
  ///
  /// Returns 0 on success, or a negative error code.
  int git_libgit2_opts_get_cached_memory(
    ffi.Pointer<ffi.Int> current,
    ffi.Pointer<ffi.Int> allowed,
  ) {
    return _git_libgit2_opts_get_cached_memory(
      git_libgit2_opt_t.GIT_OPT_GET_CACHED_MEMORY.value,
      current,
      allowed,
    );
  }

  /// Enables or disables caching completely.
  ///
  /// The [enabled] parameter should be 1 to enable caching, 0 to disable.
  /// Because caches are repository-specific, disabling the cache
  /// cannot immediately clear all cached objects, but each cache will
  /// be cleared on the next attempt to update anything in it.
  ///
  /// Returns 0 on success, or a negative error code.
  int git_libgit2_opts_enable_caching(int enabled) {
    return _git_libgit2_opts_set_int(
      git_libgit2_opt_t.GIT_OPT_ENABLE_CACHING.value,
      enabled,
    );
  }

  /// Gets the default template path.
  ///
  /// The path is written to the [out] buffer.
  ///
  /// Returns 0 on success, or a negative error code.
  int git_libgit2_opts_get_template_path(ffi.Pointer<git_buf> out) {
    return _git_libgit2_opts_get_buf(
      git_libgit2_opt_t.GIT_OPT_GET_TEMPLATE_PATH.value,
      out,
    );
  }

  /// Sets the default template path.
  ///
  /// The [path] parameter specifies the new template path.
  ///
  /// Returns 0 on success, or a negative error code.
  int git_libgit2_opts_set_template_path(ffi.Pointer<ffi.Char> path) {
    return _git_libgit2_opts_set_char(
      git_libgit2_opt_t.GIT_OPT_SET_TEMPLATE_PATH.value,
      path,
    );
  }

  /// Sets the SSL certificate-authority locations.
  ///
  /// The [file] parameter is the location of a file containing several
  /// certificates concatenated together.
  ///
  /// The [path] parameter is the location of a directory holding several
  /// certificates, one per file.
  ///
  /// Either parameter may be NULL, but not both.
  ///
  /// Returns 0 on success, or a negative error code.
  int git_libgit2_opts_set_ssl_cert_locations(
    ffi.Pointer<ffi.Char> file,
    ffi.Pointer<ffi.Char> path,
  ) {
    return _git_libgit2_opts_set_ssl_cert_locations(
      git_libgit2_opt_t.GIT_OPT_SET_SSL_CERT_LOCATIONS.value,
      file,
      path,
    );
  }

  /// Gets the value of the User-Agent header.
  ///
  /// The User-Agent is written to the [out] buffer.
  ///
  /// Returns 0 on success, or a negative error code.
  int git_libgit2_opts_get_user_agent(ffi.Pointer<git_buf> out) {
    return _git_libgit2_opts_get_buf(
      git_libgit2_opt_t.GIT_OPT_GET_USER_AGENT.value,
      out,
    );
  }

  /// Sets the value of the User-Agent header.
  ///
  /// The [user_agent] parameter specifies the value that will be delivered
  /// as the User-Agent header on HTTP requests. This value will be
  /// appended to "git/1.0" for compatibility with other git clients.
  ///
  /// Returns 0 on success, or a negative error code.
  int git_libgit2_opts_set_user_agent(ffi.Pointer<ffi.Char> user_agent) {
    return _git_libgit2_opts_set_char(
      git_libgit2_opt_t.GIT_OPT_SET_USER_AGENT.value,
      user_agent,
    );
  }

  /// Enables or disables strict input validation for new objects.
  ///
  /// When enabled (default), all inputs to new objects are validated.
  /// For example, parent(s) and tree inputs are validated when creating
  /// a new commit.
  ///
  /// The [enabled] parameter should be 1 to enable, 0 to disable.
  ///
  /// Returns 0 on success, or a negative error code.
  int git_libgit2_opts_enable_strict_object_creation(int enabled) {
    return _git_libgit2_opts_set_int(
      git_libgit2_opt_t.GIT_OPT_ENABLE_STRICT_OBJECT_CREATION.value,
      enabled,
    );
  }

  /// Enables or disables validation of symbolic ref targets.
  ///
  /// When enabled (default), the target of a symbolic ref is validated.
  /// For example, `foobar` is not a valid ref, but `refs/heads/foobar` is.
  ///
  /// The [enabled] parameter should be 1 to enable, 0 to disable.
  /// Disabling allows arbitrary strings to be used as symbolic ref targets.
  ///
  /// Returns 0 on success, or a negative error code.
  int git_libgit2_opts_enable_strict_symbolic_ref_creation(int enabled) {
    return _git_libgit2_opts_set_int(
      git_libgit2_opt_t.GIT_OPT_ENABLE_STRICT_SYMBOLIC_REF_CREATION.value,
      enabled,
    );
  }

  /// Enables or disables the use of offset deltas in packfiles.
  ///
  /// When enabled (default), offset deltas are used when creating packfiles
  /// and negotiated when talking to a remote server. Offset deltas store
  /// a delta base location as an offset into the packfile, providing
  /// shorter encoding and smaller packfiles.
  ///
  /// The [enabled] parameter should be 1 to enable, 0 to disable.
  /// Packfiles containing offset deltas can still be read regardless
  /// of this setting.
  ///
  /// Returns 0 on success, or a negative error code.
  int git_libgit2_opts_enable_offset_delta(int enabled) {
    return _git_libgit2_opts_set_int(
      git_libgit2_opt_t.GIT_OPT_ENABLE_OFS_DELTA.value,
      enabled,
    );
  }

  /// Enables or disables synchronized writes to the gitdir.
  ///
  /// When enabled, files in the gitdir are written using `fsync`
  /// (or platform equivalent) to ensure data is written to permanent
  /// storage, not just cached.
  ///
  /// The [enabled] parameter should be 1 to enable, 0 to disable.
  /// This defaults to disabled.
  ///
  /// Returns 0 on success, or a negative error code.
  int git_libgit2_opts_enable_fsync_gitdir(int enabled) {
    return _git_libgit2_opts_set_int(
      git_libgit2_opt_t.GIT_OPT_ENABLE_FSYNC_GITDIR.value,
      enabled,
    );
  }

  /// Enables or disables strict verification of object hashsums.
  ///
  /// When enabled (default), object hashsums are strictly verified
  /// when reading objects from disk. This may impact performance
  /// due to additional checksum calculations.
  ///
  /// The [enabled] parameter should be 1 to enable, 0 to disable.
  ///
  /// Returns 0 on success, or a negative error code.
  int git_libgit2_opts_enable_strict_hash_verification(int enabled) {
    return _git_libgit2_opts_set_int(
      git_libgit2_opt_t.GIT_OPT_ENABLE_STRICT_HASH_VERIFICATION.value,
      enabled,
    );
  }

  /// Enables or disables unsaved index safety checks.
  ///
  /// When enabled, operations that reload the index from disk (e.g.,
  /// checkout) will fail if there are unsaved changes in the index.
  /// Using the FORCE flag will still overwrite these changes.
  ///
  /// The [enabled] parameter should be 1 to enable, 0 to disable.
  ///
  /// Returns 0 on success, or a negative error code.
  int git_libgit2_opts_enable_unsaved_index_safety(int enabled) {
    return _git_libgit2_opts_set_int(
      git_libgit2_opt_t.GIT_OPT_ENABLE_UNSAVED_INDEX_SAFETY.value,
      enabled,
    );
  }

  /// Gets the maximum number of objects allowed in a pack file.
  ///
  /// This limit is used when downloading pack files from a remote.
  /// It can be used to limit maximum memory usage when fetching
  /// from an untrusted remote.
  ///
  /// The result is stored in [out].
  ///
  /// Returns 0 on success, or a negative error code.
  int git_libgit2_opts_get_pack_max_objects(ffi.Pointer<ffi.Int> out) {
    return _git_libgit2_opts_get_int(
      git_libgit2_opt_t.GIT_OPT_GET_PACK_MAX_OBJECTS.value,
      out,
    );
  }

  /// Sets the maximum number of objects allowed in a pack file.
  ///
  /// The [value] parameter specifies the new limit. This limit is used
  /// when downloading pack files from a remote.
  ///
  /// Returns 0 on success, or a negative error code.
  int git_libgit2_opts_set_pack_max_objects(int value) {
    return _git_libgit2_opts_set_int(
      git_libgit2_opt_t.GIT_OPT_SET_PACK_MAX_OBJECTS.value,
      value,
    );
  }

  /// Enables or disables .keep file existence checks.
  ///
  /// When enabled, .keep file existence checks are skipped when
  /// accessing packfiles. This can help performance with remote
  /// filesystems.
  ///
  /// The [enabled] parameter should be 1 to enable, 0 to disable.
  ///
  /// Returns 0 on success, or a negative error code.
  int git_libgit2_opts_disable_pack_keep_file_checks(int enabled) {
    return _git_libgit2_opts_set_int(
      git_libgit2_opt_t.GIT_OPT_DISABLE_PACK_KEEP_FILE_CHECKS.value,
      enabled,
    );
  }

  /// Enables or disables HTTP expect/continue for NTLM/Negotiate auth.
  ///
  /// When enabled, expect/continue is used when POSTing data to servers
  /// using NTLM or Negotiate authentication.
  ///
  /// The [enabled] parameter should be 1 to enable, 0 to disable.
  /// This option is not available on Windows.
  ///
  /// Returns 0 on success, or a negative error code.
  int git_libgit2_opts_enable_http_expect_continue(int enabled) {
    return _git_libgit2_opts_set_int(
      git_libgit2_opt_t.GIT_OPT_ENABLE_HTTP_EXPECT_CONTINUE.value,
      enabled,
    );
  }

  /// Gets the owner validation setting for repository directories.
  ///
  /// The result is stored in [out].
  ///
  /// Returns 0 on success, or a negative error code.
  int git_libgit2_opts_get_owner_validation(ffi.Pointer<ffi.Int> out) {
    return _git_libgit2_opts_get_int(
      git_libgit2_opt_t.GIT_OPT_GET_OWNER_VALIDATION.value,
      out,
    );
  }

  /// Sets whether repository directories should be owned by the current user.
  ///
  /// The [enabled] parameter should be 1 to enable validation (default),
  /// 0 to disable.
  ///
  /// Returns 0 on success, or a negative error code.
  int git_libgit2_opts_set_owner_validation(int enabled) {
    return _git_libgit2_opts_set_int(
      git_libgit2_opt_t.GIT_OPT_SET_OWNER_VALIDATION.value,
      enabled,
    );
  }

  /// Gets the list of supported git extensions.
  ///
  /// This includes both built-in extensions supported by libgit2 and
  /// custom extensions added with [git_libgit2_opts_set_extensions].
  /// Extensions that have been negated will not be returned.
  ///
  /// The result is stored in [out].
  ///
  /// Returns 0 on success, or a negative error code.
  int git_libgit2_opts_get_extensions(ffi.Pointer<git_strarray> out) {
    return _git_libgit2_opts_get_extensions(
      git_libgit2_opt_t.GIT_OPT_GET_EXTENSIONS.value,
      out,
    );
  }

  /// Sets the git extensions supported by the caller.
  ///
  /// The [extensions] parameter is an array of extension names.
  /// The [len] parameter specifies the number of extensions.
  ///
  /// Extensions supported by libgit2 may be negated by prefixing
  /// them with a `!`. For example: setting extensions to
  /// { "!noop", "newext" } indicates that the caller does not want
  /// to support repositories with the `noop` extension but does want
  /// to support repositories with the `newext` extension.
  ///
  /// Returns 0 on success, or a negative error code.
  int git_libgit2_opts_set_extensions(
    ffi.Pointer<ffi.Pointer<ffi.Char>> extensions,
    int len,
  ) {
    return _git_libgit2_opts_set_extensions(
      git_libgit2_opt_t.GIT_OPT_SET_EXTENSIONS.value,
      extensions,
      len,
    );
  }

  // FFI function declarations
  late final _git_libgit2_opts_get_intPtr = _lookup<
    ffi.NativeFunction<ffi.Int Function(ffi.Int, ffi.Pointer<ffi.Int>)>
  >('git_libgit2_opts');
  late final _git_libgit2_opts_get_int =
      _git_libgit2_opts_get_intPtr
          .asFunction<int Function(int, ffi.Pointer<ffi.Int>)>();

  late final _git_libgit2_opts_set_intPtr =
      _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Int, ffi.Int)>>(
        'git_libgit2_opts',
      );
  late final _git_libgit2_opts_set_int =
      _git_libgit2_opts_set_intPtr.asFunction<int Function(int, int)>();

  late final _git_libgit2_opts_get_bufPtr = _lookup<
    ffi.NativeFunction<ffi.Int Function(ffi.Int, ffi.Pointer<git_buf>)>
  >('git_libgit2_opts');
  late final _git_libgit2_opts_get_buf =
      _git_libgit2_opts_get_bufPtr
          .asFunction<int Function(int, ffi.Pointer<git_buf>)>();

  late final _git_libgit2_opts_set_charPtr = _lookup<
    ffi.NativeFunction<ffi.Int Function(ffi.Int, ffi.Pointer<ffi.Char>)>
  >('git_libgit2_opts');
  late final _git_libgit2_opts_set_char =
      _git_libgit2_opts_set_charPtr
          .asFunction<int Function(int, ffi.Pointer<ffi.Char>)>();

  late final _git_libgit2_opts_get_search_pathPtr = _lookup<
    ffi.NativeFunction<ffi.Int Function(ffi.Int, ffi.Int, ffi.Pointer<git_buf>)>
  >('git_libgit2_opts');
  late final _git_libgit2_opts_get_search_path =
      _git_libgit2_opts_get_search_pathPtr
          .asFunction<int Function(int, int, ffi.Pointer<git_buf>)>();

  late final _git_libgit2_opts_set_search_pathPtr = _lookup<
    ffi.NativeFunction<
      ffi.Int Function(ffi.Int, ffi.Int, ffi.Pointer<ffi.Char>)
    >
  >('git_libgit2_opts');
  late final _git_libgit2_opts_set_search_path =
      _git_libgit2_opts_set_search_pathPtr
          .asFunction<int Function(int, int, ffi.Pointer<ffi.Char>)>();

  late final _git_libgit2_opts_set_cache_object_limitPtr =
      _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Int, ffi.Int, ffi.Int)>>(
        'git_libgit2_opts',
      );
  late final _git_libgit2_opts_set_cache_object_limit =
      _git_libgit2_opts_set_cache_object_limitPtr
          .asFunction<int Function(int, int, int)>();

  late final _git_libgit2_opts_get_cached_memoryPtr = _lookup<
    ffi.NativeFunction<
      ffi.Int Function(ffi.Int, ffi.Pointer<ffi.Int>, ffi.Pointer<ffi.Int>)
    >
  >('git_libgit2_opts');
  late final _git_libgit2_opts_get_cached_memory =
      _git_libgit2_opts_get_cached_memoryPtr
          .asFunction<
            int Function(int, ffi.Pointer<ffi.Int>, ffi.Pointer<ffi.Int>)
          >();

  late final _git_libgit2_opts_set_ssl_cert_locationsPtr = _lookup<
    ffi.NativeFunction<
      ffi.Int Function(ffi.Int, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>)
    >
  >('git_libgit2_opts');
  late final _git_libgit2_opts_set_ssl_cert_locations =
      _git_libgit2_opts_set_ssl_cert_locationsPtr
          .asFunction<
            int Function(int, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>)
          >();

  late final _git_libgit2_opts_get_extensionsPtr = _lookup<
    ffi.NativeFunction<ffi.Int Function(ffi.Int, ffi.Pointer<git_strarray>)>
  >('git_libgit2_opts');
  late final _git_libgit2_opts_get_extensions =
      _git_libgit2_opts_get_extensionsPtr
          .asFunction<int Function(int, ffi.Pointer<git_strarray>)>();

  late final _git_libgit2_opts_set_extensionsPtr = _lookup<
    ffi.NativeFunction<
      ffi.Int Function(ffi.Int, ffi.Pointer<ffi.Pointer<ffi.Char>>, ffi.Int)
    >
  >('git_libgit2_opts');
  late final _git_libgit2_opts_set_extensions =
      _git_libgit2_opts_set_extensionsPtr
          .asFunction<
            int Function(int, ffi.Pointer<ffi.Pointer<ffi.Char>>, int)
          >();
}
