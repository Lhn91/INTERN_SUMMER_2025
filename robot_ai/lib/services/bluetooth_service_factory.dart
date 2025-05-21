import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:robot_ai/services/bluetooth_service.dart';

// Import web implementation conditionally to avoid errors on native platforms
// as dart:html is only available on web
import 'bluetooth_service_interface.dart';
import 'web_bluetooth_service.dart' if (dart.library.io) 'bluetooth_service_stub.dart';

/// Factory to create the appropriate Bluetooth service implementation
/// based on the current platform
class BluetoothServiceFactory {
  /// Creates the appropriate Bluetooth service for the current platform
  static BluetoothServiceInterface create() {
    if (kIsWeb) {
      // Return the web-specific implementation when running on web
      return WebBluetoothService();
    } else {
      // Return the native implementation for mobile/desktop platforms
      return BluetoothService();
    }
  }
} 