#include "include/git2dart_binaries/git2dart_binaries_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "git2dart_binaries_plugin.h"

void Git2dartBinariesPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  git2dart_binaries::Git2dartBinariesPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
