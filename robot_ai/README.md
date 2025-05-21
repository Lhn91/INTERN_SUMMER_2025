# Robot AI - Ứng dụng điều khiển robot thông qua Bluetooth

Ứng dụng Flutter sử dụng Flutter Hooks để quản lý state đơn giản, kết nối với robot thông qua giao tiếp Bluetooth.

## Cấu trúc thư mục

```
lib/
  ├── constants/           # Các hằng số toàn cục
  │   ├── colors.dart      # Màu sắc ứng dụng
  │   └── app_content.dart # Nội dung cố định
  │
  ├── screens/             # Các màn hình
  │   ├── connect_bluetooth_screen.dart  # Màn hình kết nối Bluetooth  
  │   ├── main_navigation_screen.dart    # Màn hình navigation chính
  │   ├── manual_control_screen.dart     # Điều khiển thủ công
  │   ├── follow_human_screen.dart       # Chế độ theo dõi người
  │   └── auto_navigation_screen.dart    # Chế độ điều hướng tự động
  │
  ├── widgets/             # Các widget dùng chung
  │   └── joystick.dart    # Widget điều khiển joystick
  │
  ├── services/            # Các dịch vụ
  │   └── bluetooth_service.dart  # Xử lý kết nối Bluetooth
  │
  ├── navigation/          # Xử lý navigation
  │   └── app_routes.dart  # Định nghĩa routes
  │
  └── main.dart            # Điểm vào ứng dụng
```

## Quản lý state bằng Flutter Hooks

Ứng dụng sử dụng Flutter Hooks để quản lý state thay vì StatefulWidget. Ví dụ:

```dart
// Thay vì StatefulWidget
class MyWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    // Khai báo state
    final counter = useState(0);
    
    return ElevatedButton(
      // Sử dụng state
      onPressed: () => counter.value++,
      child: Text('Count: ${counter.value}'),
    );
  }
}
```

## Các tính năng

1. **Kết nối Bluetooth**: Quét, kết nối đến thiết bị Bluetooth
2. **Điều khiển thủ công**: Joystick, nút xoay
3. **Theo dõi người**: Cài đặt khoảng cách, tốc độ theo dõi
4. **Điều hướng tự động**: Học và lưu lộ trình, tự động di chuyển
# ohstem-robot-ai
