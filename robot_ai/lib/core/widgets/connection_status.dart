import 'package:flutter/material.dart';

class ConnectionStatusWidget extends StatelessWidget {
  final ConnectionType type;
  final bool isConnected;
  final double strength; // 0-100

  const ConnectionStatusWidget({
    Key? key,
    required this.type,
    required this.isConnected,
    this.strength = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          type == ConnectionType.bluetooth ? Icons.bluetooth : Icons.wifi,
          size: 20,
          color: isConnected ? _getStatusColor() : Colors.grey,
        ),
        SizedBox(width: 4),
        if (isConnected && strength > 0)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              value: strength / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
              strokeWidth: 2,
            ),
          ),
      ],
    );
  }

  Color _getStatusColor() {
    if (!isConnected) return Colors.grey;
    if (strength > 70) return Colors.green;
    if (strength > 30) return Colors.orange;
    return Colors.red;
  }
}

enum ConnectionType { bluetooth, wifi }
