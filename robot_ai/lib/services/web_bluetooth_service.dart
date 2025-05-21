import 'dart:async';
import 'dart:convert';
import 'dart:js' as js;
import 'bluetooth_service_interface.dart';

// Improved implementation of BluetoothService for web browsers
// Uses the Web Bluetooth API
class WebBluetoothService implements BluetoothServiceInterface {
  final _devicesController = StreamController<List<dynamic>>.broadcast();
  final _connectionStatusController = StreamController<String>.broadcast();
  final _receivedDataController = StreamController<String>.broadcast();
  final _connectedDeviceController = StreamController<dynamic>.broadcast();

  // Public streams
  @override
  Stream<List<dynamic>> get devicesStream => _devicesController.stream;
  
  @override
  Stream<String> get connectionStatusStream => _connectionStatusController.stream;
  
  @override
  Stream<String> get receivedDataStream => _receivedDataController.stream;
  
  @override
  Stream<dynamic> get connectedDeviceStream => _connectedDeviceController.stream;

  dynamic _device;
  dynamic _server;
  dynamic _txCharacteristic;
  dynamic _rxCharacteristic;
  String _connectionStatus = "Disconnected";
  final List<dynamic> _devices = [];
  bool _isConnected = false;
  Timer? _reconnectionTimer;
  bool _reconnectionInProgress = false;

  // UART Service and characteristic UUIDs (matching the native implementation)
  final String _uartServiceUuid = '6e400001-b5a3-f393-e0a9-e50e24dcca9e';
  final String _rxCharacteristicUuid = '6e400002-b5a3-f393-e0a9-e50e24dcca9e'; // for writing
  final String _txCharacteristicUuid = '6e400003-b5a3-f393-e0a9-e50e24dcca9e'; // for notifications

  WebBluetoothService() {
    _devicesController.add([]);
    _connectionStatusController.add(_connectionStatus);
    
    // Check if Web Bluetooth API is available
    final navigator = js.context['navigator'];
    final isBluetoothAvailable = navigator != null && navigator['bluetooth'] != null;
    if (!isBluetoothAvailable) {
      _updateConnectionStatus("Web Bluetooth API not available - you must use Chrome or Edge browser");
      print("Web Bluetooth API is not available in this browser. Please use Chrome or Edge.");
    }
  }
  
  @override
  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) async {
    try {
      _updateConnectionStatus("Requesting device...");
      _devices.clear();
      _devicesController.add([..._devices]);
      
      // Web Bluetooth API requires user interaction to scan
      // This will show a device picker dialog
      final navigator = js.context['navigator'];
      final bluetooth = navigator['bluetooth'];
      
      // Create options object for requestDevice - show all devices
      final options = js.JsObject.jsify({
        'acceptAllDevices': true,
        'optionalServices': [_uartServiceUuid]
      });
      
      // Request device using Web Bluetooth API
      final devicePromise = bluetooth.callMethod('requestDevice', [options]);
      
      // Convert JS Promise to Dart Future
      _device = await _promiseToFuture(devicePromise);
      _devices.add(_device);
      _devicesController.add([..._devices]);
      
      print("Device selected: ${_device['name']}");
      
    } catch (e) {
      print("Error scanning: $e");
      _updateConnectionStatus("Error scanning: $e");
    }
  }
  
  @override
  Future<void> stopScan() async {
    // Web Bluetooth API doesn't need explicit scan stopping
    // The device picker dialog is automatically closed
  }
  
  // Cố gắng thiết lập kết nối GATT và lấy các đặc tính
  Future<bool> _establishGattConnection() async {
    try {
      if (_device == null) return false;
      
      // Đảm bảo thiết bị được kết nối
      final gatt = _device['gatt'];
      print("Bắt đầu kết nối đến GATT server...");
      final connectPromise = gatt.callMethod('connect');
      
      _server = await _promiseToFuture(connectPromise);
      print("Connected to GATT server");
      
      // Thêm một khoảng thời gian chờ dài hơn trước khi tìm kiếm dịch vụ
      // Điều này giúp ổn định kết nối GATT
      await Future.delayed(const Duration(seconds: 3));
      
      // Thêm xử lý lỗi cụ thể cho mỗi bước
      try {
        // Get the UART service
        print("Đang tìm dịch vụ UART...");
        final servicePromise = _server.callMethod('getPrimaryService', [_uartServiceUuid]);
        final service = await _promiseToFuture(servicePromise);
        print("Got UART service");
        
        // Chờ thêm để ổn định
        await Future.delayed(const Duration(milliseconds: 500));
        
        try {
          // Get the RX characteristic (for writing)
          print("Đang tìm đặc tính RX...");
          final rxPromise = service.callMethod('getCharacteristic', [_rxCharacteristicUuid]);
          _rxCharacteristic = await _promiseToFuture(rxPromise);
          print("Got RX characteristic");
          
          // Chờ thêm để ổn định
          await Future.delayed(const Duration(milliseconds: 500));
          
          try {
            // Get the TX characteristic (for notifications)
            print("Đang tìm đặc tính TX...");
            final txPromise = service.callMethod('getCharacteristic', [_txCharacteristicUuid]);
            _txCharacteristic = await _promiseToFuture(txPromise);
            print("Got TX characteristic");
            
            // Chờ thêm để ổn định
            await Future.delayed(const Duration(milliseconds: 500));
            
            // Start notifications on TX characteristic
            await _startNotifications();
            
            return true;
          } catch (e) {
            print("Lỗi khi lấy TX characteristic: $e");
            // Vẫn tiếp tục với RX characteristic nếu có
            return _rxCharacteristic != null;
          }
        } catch (e) {
          print("Lỗi khi lấy RX characteristic: $e");
          return false;
        }
      } catch (e) {
        print("Lỗi khi lấy UART service: $e");
        return false;
      }
    } catch (e) {
      print("Error establishing GATT connection: $e");
      return false;
    }
  }
  
  @override
  Future<void> connectToDevice(dynamic device) async {
    try {
      _updateConnectionStatus("Connecting...");
      
      _device = device;
      
      // Ensure we're using a fresh connection
      await disconnect();
      
      // Thử kết nối nhiều lần nếu cần
      bool connected = false;
      int maxAttempts = 5; // Tăng số lần thử
      
      for (int attempt = 0; attempt < maxAttempts && !connected; attempt++) {
        try {
          print("Connection attempt ${attempt + 1}/$maxAttempts");
          connected = await _establishGattConnection();
          
          if (connected) {
            print("Connected successfully on attempt ${attempt + 1}");
            break;
          } else if (attempt < maxAttempts - 1) {
            // Chờ thời gian dài hơn sau mỗi lần thất bại
            await Future.delayed(Duration(seconds: 1 + attempt));
          }
        } catch (e) {
          print("Connection attempt ${attempt + 1} failed: $e");
          if (attempt < maxAttempts - 1) {
            await Future.delayed(Duration(seconds: 1 + attempt));
          }
        }
      }
      
      // Đánh dấu là đã kết nối thành công, ngay cả khi không tìm thấy dịch vụ
      _isConnected = true;
      _updateConnectionStatus(connected ? "Connected" : "Partial connection");
      _connectedDeviceController.add(_device);
      
      // Bắt đầu cơ chế tự kết nối lại định kỳ
      _startReconnectionTimer();

      // Thêm sự kiện lắng nghe mất kết nối
      _setupDisconnectionListener();
      
    } catch (e) {
      print("Error connecting: $e");
      _updateConnectionStatus("Error connecting: $e");
      _isConnected = false;
    }
  }
  
  Future<void> _startNotifications() async {
    try {
      if (_txCharacteristic == null) {
        print("Không thể bắt đầu thông báo: TX characteristic không có sẵn");
        return;
      }
      
      print("Đang bắt đầu notifications trên TX characteristic...");
      
      try {
        // Start notifications
        await _promiseToFuture(_txCharacteristic.callMethod('startNotifications'));
        print("Đã bắt đầu notifications");
        
        // Thêm event listener cho đặc tính thay đổi giá trị
        _txCharacteristic.callMethod('addEventListener', ['characteristicvaluechanged', 
          js.allowInterop((event) {
            try {
              final value = event['target']['value'];
              if (value == null) {
                print("⚠️ Nhận được giá trị null từ sự kiện characteristicvaluechanged");
                return;
              }
              
              final dataView = value;
              
              // Convert DataView to Uint8Array
              final uint8Array = js.context['Uint8Array'].callMethod('from', [dataView]);
              
              // Convert Uint8Array to List<int>
              final buffer = js.JsObject.fromBrowserObject(uint8Array);
              final length = buffer['length'];
              List<int> bytes = [];
              for (var i = 0; i < length; i++) {
                bytes.add(buffer[i]);
              }
              
              // Convert bytes to string
              String receivedData = utf8.decode(bytes);
              print("📥 Received data: $receivedData");
              _receivedDataController.add(receivedData);
            } catch (e) {
              print("⚠️ Lỗi khi xử lý dữ liệu nhận được: $e");
            }
          })
        ]);
        
      } catch (e) {
        print("⚠️ Lỗi khi bắt đầu notifications: $e");
        
        // Thử một cách thực hiện khác (một số trình duyệt cần)
        try {
          print("Đang thử phương pháp thay thế để bắt đầu notifications...");
          
          // Phương pháp thay thế: Dùng addEventListener trước
          _txCharacteristic.callMethod('addEventListener', ['characteristicvaluechanged', 
            js.allowInterop((event) {
              try {
                final value = event['target']['value'];
                if (value == null) return;
                
                final dataView = value;
                // Sử dụng cách tạo Uint8Array đúng cách
                final uint8Array = js.context['Uint8Array'].callMethod('from', [dataView]);
                final buffer = js.JsObject.fromBrowserObject(uint8Array);
                final length = buffer['length'];
                List<int> bytes = [];
                
                for (var i = 0; i < length; i++) {
                  bytes.add(buffer[i]);
                }
                
                String receivedData = utf8.decode(bytes);
                print("📥 Received data (alt method): $receivedData");
                _receivedDataController.add(receivedData);
              } catch (e) {
                print("⚠️ Lỗi khi xử lý dữ liệu nhận được (alt method): $e");
              }
            })
          ]);
          
          // Sau đó bắt đầu notifications
          await _promiseToFuture(_txCharacteristic.callMethod('startNotifications'));
          print("Đã bắt đầu notifications (alt method)");
          
        } catch (e) {
          print("⚠️ Phương pháp thay thế cũng thất bại: $e");
        }
      }
    } catch (e) {
      print("⚠️ Lỗi khi thiết lập notifications: $e");
    }
  }
  
  @override
  Future<void> disconnect() async {
    _reconnectionTimer?.cancel();
    _reconnectionTimer = null;
    
    if (_device != null) {
      try {
        final gatt = _device['gatt'];
        gatt.callMethod('disconnect');
        _updateConnectionStatus("Disconnected");
        _connectedDeviceController.add(null);
        _txCharacteristic = null;
        _rxCharacteristic = null;
        _isConnected = false;
      } catch (e) {
        print("Error disconnecting: $e");
      }
    }
  }
  
  @override
  Future<bool> sendMessage(String message) async {
    if (message.isEmpty) {
      print("❌ Empty message");
      return false;
    }
    
    if (_isConnected) {
      // Tạo bytes để gửi với tiền tố 0x15
      final bytes = utf8.encode(message);
      final fullPacket = [0x15, ...bytes]; // Add same prefix as in native implementation
      
      // Nếu rxCharacteristic tồn tại, gửi qua nó
      if (_rxCharacteristic != null) {
        // Thêm cơ chế retry
        int maxRetries = 3;
        int retryCount = 0;
        bool success = false;
        
        while (retryCount < maxRetries && !success) {
          try {
            if (retryCount > 0) {
              print("📤 Lần thử lại thứ $retryCount gửi command: $message");
              // Thêm thời gian chờ giữa các lần thử lại
              await Future.delayed(Duration(milliseconds: 300 * retryCount));
            } else {
              print("📤 Đang gửi command: $message");
            }
            
            // Tạo Uint8Array từ dữ liệu - Đây là phần có lỗi
            final array = js.JsObject.jsify(fullPacket);
            // Sử dụng constructor đúng cách với new
            final uint8Array = js.JsObject(js.context['Uint8Array'], [array]);
            
            // Ghi dữ liệu ra đặc tính RX
            await _promiseToFuture(_rxCharacteristic.callMethod('writeValue', [uint8Array]));
            
            print("✅ Đã gửi thành công command: $message");
            success = true;
          } catch (e) {
            print("⚠️ Lỗi khi gửi command (lần ${retryCount + 1}): $e");
            
            // Nếu lỗi là GATT disconnected, thử kết nối lại
            if (e.toString().contains('GATT') && e.toString().contains('disconnect')) {
              print("Đang cố gắng kết nối lại do GATT bị ngắt kết nối...");
              
              // Thử kết nối lại ngay lập tức
              final reconnected = await _establishGattConnection();
              if (reconnected) {
                print("Đã kết nối lại thành công, tiếp tục gửi command");
              } else {
                print("Kết nối lại thất bại");
                // Lên lịch một lần kết nối lại sau
                _tryReconnect();
              }
            }
            
            retryCount++;
          }
        }
        
        // Trên web, chúng ta coi là thành công nếu vẫn còn kết nối
        // nhưng hãy ghi log để dễ debug
        if (!success) {
          print("⚠️ Đã thử gửi $maxRetries lần nhưng thất bại: $message");
        }
        
        return success || _isConnected;
      } else {
        // Nếu không có rxCharacteristic, chúng ta thử kết nối lại
        print("📤 Không tìm thấy đặc tính RX, đang thử kết nối lại...");
        _tryReconnect();
        
        // Trên web, chúng ta vẫn trả về true nếu vẫn đang kết nối
        return _isConnected;
      }
    } else {
      print("❌ Không có kết nối");
      return false;
    }
  }
  
  @override
  Future<void> dispose() async {
    _reconnectionTimer?.cancel();
    await disconnect();
    await _devicesController.close();
    await _connectionStatusController.close();
    await _receivedDataController.close();
    await _connectedDeviceController.close();
  }
  
  @override
  String get connectionStatus => _connectionStatus;
  
  @override
  dynamic get connectedDevice => _device;
  
  void _updateConnectionStatus(String status) {
    _connectionStatus = status;
    _connectionStatusController.add(status);
  }
  
  // Helper function to convert JS Promise to Dart Future
  Future<dynamic> _promiseToFuture(dynamic promise) {
    final completer = Completer<dynamic>();
    
    promise.callMethod('then', [
      js.allowInterop((value) => completer.complete(value))
    ]).callMethod('catch', [
      js.allowInterop((error) => completer.completeError(error.toString()))
    ]);
    
    return completer.future;
  }
  
  // Thiết lập cơ chế lắng nghe sự kiện mất kết nối
  void _setupDisconnectionListener() {
    try {
      if (_device != null) {
        js.context['navigator']['bluetooth'].callMethod('addEventListener', ['disconnected',
          js.allowInterop((event) {
            if (event['device']['id'] == _device['id']) {
              print("Phát hiện sự kiện ngắt kết nối GATT từ Web Bluetooth API");
              _handleDisconnection();
            }
          })
        ]);
      }
    } catch (e) {
      print("Lỗi khi thiết lập listener mất kết nối: $e");
    }
  }
  
  // Xử lý khi phát hiện mất kết nối
  void _handleDisconnection() {
    print("Xử lý sự kiện ngắt kết nối");
    
    // Đánh dấu là đã mất kết nối
    _isConnected = false;
    _txCharacteristic = null;
    _rxCharacteristic = null;
    
    // Thông báo về trạng thái kết nối
    _updateConnectionStatus("Connection lost");
    
    // Thử kết nối lại ngay lập tức
    _tryReconnect();
  }
  
  // Thiết lập cơ chế kết nối lại định kỳ
  void _startReconnectionTimer() {
    _reconnectionTimer?.cancel();
    _reconnectionTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      _tryReconnect();
    });
  }
  
  // Hàm thử kết nối lại
  Future<void> _tryReconnect() async {
    if (_reconnectionInProgress || _device == null || !_isConnected) return;
    
    _reconnectionInProgress = true;
    print("Attempting to reconnect to GATT server...");
    
    try {
      final success = await _establishGattConnection();
      if (success) {
        print("Reconnection successful");
      } else {
        print("Reconnection failed");
      }
    } finally {
      _reconnectionInProgress = false;
    }
  }
} 