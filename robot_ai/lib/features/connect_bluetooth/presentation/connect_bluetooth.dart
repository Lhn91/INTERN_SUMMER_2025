// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'package:robot_ai/services/bluetooth_service_interface.dart';

class BleCommunicatorPage extends StatefulWidget {
  const BleCommunicatorPage({super.key});

  @override
  State<BleCommunicatorPage> createState() => _BleCommunicatorPageState();
}

class _BleCommunicatorPageState extends State<BleCommunicatorPage> {
  late BluetoothServiceInterface bluetoothService;
  final String _testMessage = "Test Message";
  bool _isConnecting = false;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    // Không tự động quét nữa để tránh lỗi trên web
    Future.microtask(() {
      bluetoothService = Provider.of<BluetoothServiceInterface>(context, listen: false);
      // Không gọi startScan ở đây nữa
    });
  }

  @override
  void dispose() {
    bluetoothService.stopScan();
    super.dispose();
  }

  void _connectAndSendMessage(dynamic device) async {
    await bluetoothService.disconnect();
    setState(() {
      _isConnecting = true;
    });

    // Hiển thị loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text("Đang kết nối..."),
            if (kIsWeb) 
              const Padding(
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  "Lưu ý: Kết nối trên web có thể mất nhiều thời gian hơn.",
                  style: TextStyle(
                    fontSize: 12, 
                    fontStyle: FontStyle.italic,
                    color: Colors.grey
                  ),
                  textAlign: TextAlign.center,
                ),
              )
          ],
        ),
      ),
    );

    // Bắt đầu kết nối
    await bluetoothService.connectToDevice(device);

    // Chờ lâu hơn khi đang ở môi trường web
    if (kIsWeb) {
      await Future.delayed(const Duration(seconds: 8));
    } else {
      await Future.delayed(const Duration(milliseconds: 3500));
    }
    
    // Kiểm tra trạng thái kết nối trước khi gửi tin nhắn
    String currentStatus = bluetoothService.connectionStatus;
    
    // Thử gửi một tin nhắn test 
    bool success = false;
    
    // Trên web, chúng ta thử gửi nhiều lần nếu cần
    if (kIsWeb && currentStatus.contains("Connected") || currentStatus.contains("Partial")) {
      // Thử gửi tin nhắn nhiều lần trên web
      for (int i = 0; i < 3 && !success; i++) {
        success = await bluetoothService.sendMessage(_testMessage);
        if (!success) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    } else {
      // Gửi một lần duy nhất trên mobile
      success = await bluetoothService.sendMessage(_testMessage);
    }

    // Đóng dialog loading
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    setState(() {
      _isConnecting = false;
    });

    // Trên web, chúng ta ưu tiên chuyển trang sau khi đã kết nối, ngay cả khi không gửi được tin nhắn test
    if (success || (kIsWeb && (currentStatus.contains("Connected") || currentStatus.contains("Partial")))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kết nối thành công!"),
          backgroundColor: Colors.green,
        ),
      );

      // Chuyển sang trang tiếp theo
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushNamed(context, '/control');
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Kết nối thất bại: $currentStatus. Vui lòng thử lại."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Hàm quét thiết bị mới
  void _startScan() {
    setState(() {
      _isScanning = true;
    });
    bluetoothService.startScan().then((_) {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }).catchError((e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi quét: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bluetoothService = Provider.of<BluetoothServiceInterface>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm thiết bị'),
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.stop : Icons.refresh),
            onPressed: _isScanning
                ? () {
                    bluetoothService.stopScan();
                    setState(() {
                      _isScanning = false;
                    });
                  }
                : _startScan,
            tooltip: _isScanning ? 'Dừng quét' : 'Quét lại',
          ),
        ],
      ),
      body: Column(
        children: [
          // Indicator khi đang scan
          Container(
            color: Colors.blue.shade50,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                if (_isScanning)
                  Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.only(right: 8),
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                Text(
                  _isScanning
                      ? 'Đang quét thiết bị Bluetooth...'
                      : 'Nhấn nút quét để tìm kiếm thiết bị',
                  style: TextStyle(
                    color: _isScanning
                        ? Colors.blue.shade700
                        : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),

          // Thông báo cho web
          if (kIsWeb)
            Container(
              color: Colors.orange.shade100,
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lưu ý khi sử dụng trên trình duyệt:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Chỉ hoạt động trên Chrome hoặc Edge\n'
                    '• Bạn phải nhấn vào nút Quét để hiện hộp thoại lựa chọn thiết bị\n'
                    '• Cần cho phép quyền truy cập Bluetooth\n'
                    '• HTTPS hoặc localhost là bắt buộc để sử dụng Bluetooth Web',
                  ),
                ],
              ),
            ),

          // Nút Quét lớn ở giữa khi chưa có thiết bị
          if (!_isScanning)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: ElevatedButton.icon(
                onPressed: _startScan,
                icon: const Icon(Icons.bluetooth_searching, size: 24),
                label: const Text('QUÉT THIẾT BỊ', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),

          // Danh sách thiết bị
          Expanded(
            child: StreamBuilder<dynamic>(
              stream: bluetoothService.devicesStream,
              builder: (context, snapshot) {
                if (_isScanning && !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final devices = snapshot.data ?? [];

                if (devices.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bluetooth_searching,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'Không tìm thấy thiết bị nào',
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: devices.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    bool isConnected = false;
                    
                    // Handle both web and mobile device objects
                    if (kIsWeb) {
                      final connectedDevice = bluetoothService.connectedDevice;
                      isConnected = connectedDevice != null && 
                                    connectedDevice['id'] == device['id'];
                    } else {
                      isConnected = bluetoothService.connectedDevice?.id == device.id;
                    }

                    String deviceName = kIsWeb 
                        ? (device['name'] ?? "Thiết bị không xác định")
                        : (device.name.isEmpty ? "Thiết bị không xác định" : device.name);
                    
                    String deviceId = kIsWeb 
                        ? device['id'] 
                        : device.id;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      elevation: 2,
                      child: ListTile(
                        leading: Icon(
                          isConnected
                              ? Icons.bluetooth_connected
                              : Icons.bluetooth,
                          color: isConnected ? Colors.blue : Colors.grey,
                          size: 32,
                        ),
                        title: Text(
                          deviceName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ID: $deviceId'),
                            if (!kIsWeb) Text('RSSI: ${device.rssi} dBm'),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: _isConnecting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.chevron_right),
                        onTap: _isConnecting
                            ? null
                            : () => _connectAndSendMessage(device),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
