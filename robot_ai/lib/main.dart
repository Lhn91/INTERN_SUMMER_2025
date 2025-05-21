import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:robot_ai/core/constants/colors.dart';
import 'package:robot_ai/core/constants/contents.dart';
import 'package:robot_ai/core/providers/bluetooth_service.dart';
import 'package:robot_ai/navigation/app_router.dart' hide AppRouter, AppRoutes;
import 'package:robot_ai/navigation/app_router.dart';
import 'package:robot_ai/services/bluetooth_service_interface.dart';
import 'package:robot_ai/services/bluetooth_service_factory.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Use the factory to get the appropriate Bluetooth service implementation for the current platform
  final bluetoothService = BluetoothServiceFactory.create();
      
  runApp(
    Provider<BluetoothServiceInterface>.value(
      value: bluetoothService,
      child: RobotAIApp(),
    ),
  );
}

class RobotAIApp extends StatelessWidget {
  RobotAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppContents.appName,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: '/',
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.background,
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.primary,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        secondary: AppColors.accentDark,
        surface: AppColors.darkBackground,
        background: AppColors.darkBackground,
        error: AppColors.error,
      ),
      // Các customizations khác cho dark theme
    );
  }
}
