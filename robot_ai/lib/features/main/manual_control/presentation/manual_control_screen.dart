// lib/features/manual_control/presentation/manual_control_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_ai/core/constants/intructions.dart';
import 'package:robot_ai/features/main/manual_control/presentation/widgets/joysticks.dart';
import 'package:robot_ai/features/main/manual_control/presentation/widgets/tracking_status.dart';
import 'package:robot_ai/services/bluetooth_service_interface.dart';

class ManualControlPage extends StatefulWidget {
  const ManualControlPage({Key? key}) : super(key: key);

  @override
  State<ManualControlPage> createState() => _ManualControlPageState();
}

class _ManualControlPageState extends State<ManualControlPage> {
  Offset _leftJoystickValue = Offset.zero;
  final TrackingStatus _trackingStatus = TrackingStatus.tracking;
  Timer? _rotateTimer;
  late BluetoothServiceInterface bluetoothService;
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bluetoothService = Provider.of<BluetoothServiceInterface>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Control'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bluetooth_disabled),
            tooltip: 'Disconnect',
            onPressed: _disconnectDevice,
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child:
                      _buildJoystickIndicator('Movement', _leftJoystickValue),
                ),
                TrackingStatusWidget(status: _trackingStatus),
              ],
            ),
            const Spacer(),
            // LeftJoystick(
            //   onDirectionChanged: (value) {
            //     setState(() => _leftJoystickValue = value);
            //     _sendMovementCommand();
            //   },
            // ),
            const SizedBox(height: 32),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildRotateButton(
                        Icons.rotate_left, RobotInstructions.turnLeft),
                    const SizedBox(width: 16),
                    _buildRotateButton(Icons.arrow_upward_sharp,
                        RobotInstructions.moveForward),
                    const SizedBox(width: 16),
                    _buildRotateButton(
                        Icons.rotate_right, RobotInstructions.turnRight),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildRotateButton(
                        Icons.arrow_back_outlined, RobotInstructions.moveLeft),
                    const SizedBox(width: 16),
                    _buildRotateButton(Icons.arrow_downward_sharp,
                        RobotInstructions.moveBackward),
                    const SizedBox(width: 16),
                    _buildRotateButton(Icons.arrow_forward_outlined,
                        RobotInstructions.moveRight),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoystickIndicator(String label, Offset value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: X=${value.dx.toStringAsFixed(2)}, Y=${value.dy.toStringAsFixed(2)}',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildRotateButton(IconData icon, String direction) {
    return GestureDetector(
      onTapDown: (_) => _startRotation(direction),
      onTapUp: (_) => _stopRotation(),
      onTapCancel: _stopRotation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 38),
      ),
    );
  }

  void _startRotation(String direction) {
    _sendRotationCommand(direction); // gọi ngay khi bắt đầu
    // _rotateTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
    //   _sendRotationCommand(direction);
    // });
  }

  // void _sendMovementCommand() {
  //   final x = _leftJoystickValue.dx;
  //   final y = _leftJoystickValue.dy;
  //   final message = 'move:${x.toStringAsFixed(2)},${y.toStringAsFixed(2)}';

  //   debugPrint('Sending movement command: $message');

  //   bluetoothService.sendMessage(message).then((success) {
  //     if (!success) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Failed to send movement command')),
  //       );
  //     }
  //   });
  // }

  void _sendRotationCommand(String direction) {
    final message = direction;

    debugPrint('Sending rotation command: $message');

    bluetoothService.sendMessage(message).then((success) {
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send rotation command')),
        );
      }
    });
  }

  void _stopRotation() {
    _rotateTimer?.cancel();
    _rotateTimer = null;

    debugPrint('Sending rotation command: ${RobotInstructions.stop}');

    bluetoothService.sendMessage(RobotInstructions.stop).then((success) {
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send rotation command')),
        );
      }
    });
  }

  Future<void> _disconnectDevice() async {
    await bluetoothService.disconnect();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Disconnected from device')),
      );
      Navigator.pushNamed(context, '/');
    }
  }
}
