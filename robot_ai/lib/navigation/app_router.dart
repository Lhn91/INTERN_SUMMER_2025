import 'package:flutter/material.dart';
import 'package:robot_ai/features/connect_bluetooth/presentation/connect_bluetooth.dart';
import 'package:robot_ai/features/main/MainNavigation.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const BleCommunicatorPage());
      case '/control':
        return MaterialPageRoute(builder: (_) => const MainNavigationScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Không tìm thấy trang')),
          ),
        );
    }
  }
}

class AppRoutes {
  static const String home = '/';
  static const String control = '/control';
}
// Navigator.pushNamed(context, AppRoutes.followHuman);