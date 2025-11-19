// git2dart_binaries_plugin.cpp
// Minimal plugin implementation for FFI-only Android plugin
// Copy this file to git2dart_binaries/android/src/main/cpp/

#include <flutter/plugin_registrar.h>

namespace git2dart_binaries {

// Plugin registration function
// For FFI plugins, this is mostly a no-op as the actual library loading
// happens through Dart's FFI, not through method channels
void Git2dartBinariesPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  // No method channels or platform-specific code needed
  // All functionality is handled via FFI from Dart side
}

}  // namespace git2dart_binaries
