import 'dart:async';

/// An interface defining the contract for all Bluetooth service implementations
abstract class BluetoothServiceInterface {
  /// Stream of available Bluetooth devices
  Stream get devicesStream;
  
  /// Stream of the connection status
  Stream<String> get connectionStatusStream;
  
  /// Stream of received data from the connected device
  Stream<String> get receivedDataStream;
  
  /// Stream of the currently connected device
  Stream get connectedDeviceStream;
  
  /// Current connection status
  String get connectionStatus;
  
  /// Current connected device
  dynamic get connectedDevice;
  
  /// Start scanning for Bluetooth devices
  Future<void> startScan({Duration timeout});
  
  /// Stop scanning for Bluetooth devices
  Future<void> stopScan();
  
  /// Connect to a Bluetooth device
  Future<void> connectToDevice(dynamic device);
  
  /// Disconnect from the currently connected device
  Future<void> disconnect();
  
  /// Send a message to the connected device
  Future<bool> sendMessage(String message);
  
  /// Clean up resources
  Future<void> dispose();
} 