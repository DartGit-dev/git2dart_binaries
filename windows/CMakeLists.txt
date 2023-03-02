cmake_minimum_required(VERSION 3.14)
set(PROJECT_NAME "git2dart")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "git2dart_binaries_plugin")

add_library(${PLUGIN_NAME} SHARED
  "git2dart_binaries_plugin.cpp"
)
apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)

# List of absolute paths to libraries that should be bundled with the plugin
set(git2dart_binaries_bundled_libraries
  "${CMAKE_CURRENT_SOURCE_DIR}/libgit2-1.6.2.dll"
  "${CMAKE_CURRENT_SOURCE_DIR}/libcrypto-1_1-x64.dll"
  "${CMAKE_CURRENT_SOURCE_DIR}/libssh2.dll"
  PARENT_SCOPE
)
