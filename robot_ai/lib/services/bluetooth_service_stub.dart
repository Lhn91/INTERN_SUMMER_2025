import 'dart:async';
import 'bluetooth_service_interface.dart';

/// Stub implementation to avoid compilation errors when conditionally importing
/// This class should never be instantiated or used directly
class WebBluetoothService implements BluetoothServiceInterface {
  @override
  Stream get devicesStream => throw UnimplementedError('Stub implementation - not for actual use');

  @override
  Stream<String> get connectionStatusStream => throw UnimplementedError('Stub implementation - not for actual use');

  @override
  Stream<String> get receivedDataStream => throw UnimplementedError('Stub implementation - not for actual use');

  @override
  Stream get connectedDeviceStream => throw UnimplementedError('Stub implementation - not for actual use');

  @override
  String get connectionStatus => throw UnimplementedError('Stub implementation - not for actual use');

  @override
  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) {
    throw UnimplementedError('Stub implementation - not for actual use');
  }

  @override
  Future<void> stopScan() {
    throw UnimplementedError('Stub implementation - not for actual use');
  }

  @override
  Future<void> connectToDevice(device) {
    throw UnimplementedError('Stub implementation - not for actual use');
  }

  @override
  Future<void> disconnect() {
    throw UnimplementedError('Stub implementation - not for actual use');
  }

  @override
  Future<bool> sendMessage(String message) {
    throw UnimplementedError('Stub implementation - not for actual use');
  }

  @override
  Future<void> dispose() {
    throw UnimplementedError('Stub implementation - not for actual use');
  }
} 