import 'package:flutter/material.dart';
import 'package:robot_ai/services/bluetooth_service_interface.dart';
import 'package:robot_ai/services/bluetooth_service_factory.dart';

class BluetoothServiceProvider extends ChangeNotifier {
  BluetoothServiceInterface _bluetoothService = BluetoothServiceFactory.create();

  BluetoothServiceInterface get service => _bluetoothService;

  Future<void> disposeService() async {
    await _bluetoothService.dispose();
    super.dispose();
  }
}
