import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:robot_ai/features/connect_bluetooth/presentation/connect_bluetooth.dart';

class ConnectBluetoothScreen extends StatelessWidget {
  const ConnectBluetoothScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BleCommunicatorPage();
  }
}
