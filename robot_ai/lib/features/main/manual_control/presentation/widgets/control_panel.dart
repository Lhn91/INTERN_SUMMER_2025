import 'package:flutter/material.dart';
import 'package:robot_ai/core/constants/colors.dart';

class ControlPanel extends StatelessWidget {
  final VoidCallback onRecordPressed;
  final VoidCallback onStopPressed;
  final VoidCallback onResetPressed;
  final bool isRecording;

  const ControlPanel({
    Key? key,
    required this.onRecordPressed,
    required this.onStopPressed,
    required this.onResetPressed,
    this.isRecording = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.darkBackground.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildControlButton(
            icon: isRecording ? Icons.stop : Icons.fiber_manual_record,
            label: isRecording ? 'STOP REC' : 'REC ROUTE',
            color: isRecording ? Colors.red : AppColors.accent,
            onPressed: onRecordPressed,
          ),
          _buildControlButton(
            icon: Icons.stop,
            label: 'STOP',
            color: Colors.red,
            onPressed: onStopPressed,
          ),
          _buildControlButton(
            icon: Icons.replay,
            label: 'RESET',
            color: Colors.blue,
            onPressed: onResetPressed,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, size: 28),
          color: color,
          onPressed: onPressed,
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
