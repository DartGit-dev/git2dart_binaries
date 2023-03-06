#include "include/git2dart_binaries/git2dart_binaries_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>

#define GIT2DART_BINARIES_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), git2dart_binaries_plugin_get_type(), \
                              Git2dartBinariesPlugin))

struct _Git2dartBinariesPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(Git2dartBinariesPlugin, git2dart_binaries_plugin, g_object_get_type())

// Called when a method call is received from Flutter.
static void git2dart_binaries_plugin_handle_method_call(
    Git2dartBinariesPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "getPlatformVersion") == 0) {
    struct utsname uname_data = {};
    uname(&uname_data);
    g_autofree gchar *version = g_strdup_printf("Linux %s", uname_data.version);
    g_autoptr(FlValue) result = fl_value_new_string(version);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void git2dart_binaries_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(git2dart_binaries_plugin_parent_class)->dispose(object);
}

static void git2dart_binaries_plugin_class_init(Git2dartBinariesPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = git2dart_binaries_plugin_dispose;
}

static void git2dart_binaries_plugin_init(Git2dartBinariesPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  Git2dartBinariesPlugin* plugin = GIT2DART_BINARIES_PLUGIN(user_data);
  git2dart_binaries_plugin_handle_method_call(plugin, method_call);
}

void git2dart_binaries_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  Git2dartBinariesPlugin* plugin = GIT2DART_BINARIES_PLUGIN(
      g_object_new(git2dart_binaries_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "git2dart_binaries",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}
