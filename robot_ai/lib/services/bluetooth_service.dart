import 'dart:async';
import 'dart:convert';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'bluetooth_service_interface.dart';

class BluetoothService implements BluetoothServiceInterface {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  StreamSubscription<DiscoveredDevice>? _scanSubscription;
  StreamSubscription<ConnectionStateUpdate>? _connection;
  StreamSubscription<List<int>>? _notifySubscription;
  final _connectedDeviceController =
      StreamController<DiscoveredDevice?>.broadcast();
  
  @override
  Stream<DiscoveredDevice?> get connectedDeviceStream => _connectedDeviceController.stream;

  // Device management
  final List<DiscoveredDevice> _devices = [];
  DiscoveredDevice? _connectedDevice;
  String _connectionStatus = "Disconnected";

  // Characteristics
  QualifiedCharacteristic? _writeCharacteristic;
  QualifiedCharacteristic? _notifyCharacteristic;

  // Stream controllers for exposing data
  final _devicesController =
      StreamController<List<DiscoveredDevice>>.broadcast();
  final _connectionStatusController = StreamController<String>.broadcast();
  final _receivedDataController = StreamController<String>.broadcast();

  // Public streams
  @override
  Stream<List<DiscoveredDevice>> get devicesStream => _devicesController.stream;
  
  @override
  Stream<String> get connectionStatusStream =>
      _connectionStatusController.stream;
  
  @override
  Stream<String> get receivedDataStream => _receivedDataController.stream;

  BluetoothService() {
    // Initialize with empty lists
    _devicesController.add([]);
    _connectionStatusController.add(_connectionStatus);
  }

  @override
  Future<void> dispose() async {
    await _scanSubscription?.cancel();
    await _connection?.cancel();
    await _notifySubscription?.cancel();
    await _devicesController.close();
    await _connectionStatusController.close();
    await _receivedDataController.close();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.location,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
  }

  @override
  Future<void> startScan(
      {Duration timeout = const Duration(seconds: 10)}) async {
    await _requestPermissions();

    if (_scanSubscription != null) {
      return;
    }

    _devices.clear();
    _devicesController.add([..._devices]);

    _scanSubscription = _ble.scanForDevices(
      withServices: [],
      scanMode: ScanMode.lowLatency,
    ).listen((device) {
      if (!_devices.any((d) => d.id == device.id)) {
        // Filter for specific devices if needed
        if (!device.name.contains('ohstem')) return;

        _devices.add(device);
        _devicesController.add([..._devices]);
      }
    });

    // Stop scanning after timeout
    if (timeout != Duration.zero) {
      Future.delayed(timeout, stopScan);
    }
  }

  @override
  Future<void> stopScan() async {
    await _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  @override
  Future<void> connectToDevice(dynamic device) async {
    try {
      _updateConnectionStatus("Connecting...");

      await _connection?.cancel();
      _connection = _ble
          .connectToDevice(
        id: device.id,
        servicesWithCharacteristicsToDiscover: {},
        connectionTimeout: const Duration(seconds: 10),
      )
          .listen((update) {
        _updateConnectionStatus(update.connectionState.toString());

        if (update.connectionState == DeviceConnectionState.connected) {
          _connectedDevice = device;
          _connectedDeviceController.add(device); // Thêm dòng này
          _discoverServices(device.id);
        } else if (update.connectionState ==
            DeviceConnectionState.disconnected) {
          _connectedDevice = null;
          _connectedDeviceController.add(null);
          _writeCharacteristic = null;
          _notifyCharacteristic = null;
        }
      }, onError: (error) {
        print("Connection error: $error");
        _updateConnectionStatus("Connection failed");
      });
    } catch (e) {
      print("Error connecting: $e");
      _updateConnectionStatus("Error connecting");
    }
  }

  Future<void> _discoverServices(String deviceId) async {
    try {
      final services = await _ble.discoverServices(deviceId);

      for (final service in services) {
        if (service.serviceId ==
            Uuid.parse("6e400001-b5a3-f393-e0a9-e50e24dcca9e")) {
          for (final characteristic in service.characteristics) {
            final charId = characteristic.characteristicId;
            // RX characteristic - for writing data (client -> device)
            if (charId == Uuid.parse("6e400002-b5a3-f393-e0a9-e50e24dcca9e") &&
                (characteristic.isWritableWithResponse ||
                    characteristic.isWritableWithoutResponse)) {
              _writeCharacteristic = QualifiedCharacteristic(
                serviceId: service.serviceId,
                characteristicId: charId,
                deviceId: deviceId,
              );
            }
            // TX characteristic - for receiving notifications (device -> client)
            else if (charId ==
                    Uuid.parse("6e400003-b5a3-f393-e0a9-e50e24dcca9e") &&
                characteristic.isNotifiable) {
              _notifyCharacteristic = QualifiedCharacteristic(
                serviceId: service.serviceId,
                characteristicId: charId,
                deviceId: deviceId,
              );
            }
          }
        }
      }

      if (_notifyCharacteristic != null) {
        // Subscribe to notifications
        _notifySubscription?.cancel();
        _notifySubscription = _ble
            .subscribeToCharacteristic(_notifyCharacteristic!)
            .listen((data) {
          final receivedString = utf8.decode(data);
          print("📥 Received data: $receivedString");
          _receivedDataController.add(receivedString);
        });
      }

      if (_writeCharacteristic == null) {
        print("No writable RX characteristic found!");
      }
      if (_notifyCharacteristic == null) {
        print("No notify TX characteristic found!");
      }
    } catch (e) {
      print("Error discovering services: $e");
    }
  }

  @override
  Future<void> disconnect() async {
    await _connection?.cancel();
    await _notifySubscription?.cancel();

    _connectedDevice = null;
    _writeCharacteristic = null;
    _notifyCharacteristic = null;
    _updateConnectionStatus("Disconnected");
  }

  @override
  Future<bool> sendMessage(String message) async {
    if (_writeCharacteristic == null || message.isEmpty) {
      print("❌ No characteristic or empty content");
      return false;
    }

    try {
      final bytes = utf8.encode(message);

      await _ble.writeCharacteristicWithResponse(
        _writeCharacteristic!,
        value: [0x15] + bytes,
      );

      return true;
    } catch (e) {
      print("⚠️ Error sending: $e");
      return false;
    }
  }

  DiscoveredDevice? get connectedDevice => _connectedDevice;
  
  @override
  String get connectionStatus => _connectionStatus;

  void _updateConnectionStatus(String status) {
    _connectionStatus = status;
    _connectionStatusController.add(status);
  }
}
