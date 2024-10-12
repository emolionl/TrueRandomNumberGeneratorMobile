//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <bluetooth_low_energy_windows/bluetooth_low_energy_windows_plugin_c_api.h>
#include <cloud_firestore/cloud_firestore_plugin_c_api.h>
#include <connectivity_plus_windows/connectivity_plus_windows_plugin.h>
#include <firebase_auth/firebase_auth_plugin_c_api.h>
#include <firebase_core/firebase_core_plugin_c_api.h>
#include <flutter_libserialport/flutter_libserialport_plugin.h>
#include <permission_handler_windows/permission_handler_windows_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  BluetoothLowEnergyWindowsPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("BluetoothLowEnergyWindowsPluginCApi"));
  CloudFirestorePluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("CloudFirestorePluginCApi"));
  ConnectivityPlusWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ConnectivityPlusWindowsPlugin"));
  FirebaseAuthPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FirebaseAuthPluginCApi"));
  FirebaseCorePluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FirebaseCorePluginCApi"));
  FlutterLibserialportPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterLibserialportPlugin"));
  PermissionHandlerWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("PermissionHandlerWindowsPlugin"));
}
