import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:robot_ai/features/main/manual_control/presentation/manual_control_screen.dart';
import 'package:robot_ai/services/bluetooth_service_interface.dart';
import 'package:robot_ai/core/widgets/joystick.dart';

class ManualControlScreen extends StatelessWidget {
  const ManualControlScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ManualControlPage();
  }
}