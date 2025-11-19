# CMakeLists.txt for Android platform
cmake_minimum_required(VERSION 3.10)

project(git2dart_binaries LANGUAGES C)

# For FFI plugins, we only need to bundle the native libraries
# No actual plugin code is needed

# List of absolute paths to libraries that should be bundled with the plugin.
# Flutter will automatically include these in the APK under lib/${ANDROID_ABI}/
set(git2dart_binaries_bundled_libraries
  "${CMAKE_CURRENT_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI}/libgit2.so"
  PARENT_SCOPE
)
