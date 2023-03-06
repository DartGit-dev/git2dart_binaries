#ifndef FLUTTER_PLUGIN_GIT2DART_BINARIES_PLUGIN_H_
#define FLUTTER_PLUGIN_GIT2DART_BINARIES_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace git2dart_binaries {

class Git2dartBinariesPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  Git2dartBinariesPlugin();

  virtual ~Git2dartBinariesPlugin();

  // Disallow copy and assign.
  Git2dartBinariesPlugin(const Git2dartBinariesPlugin&) = delete;
  Git2dartBinariesPlugin& operator=(const Git2dartBinariesPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace git2dart_binaries

#endif  // FLUTTER_PLUGIN_GIT2DART_BINARIES_PLUGIN_H_
