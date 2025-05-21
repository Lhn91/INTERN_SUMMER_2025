import 'package:flutter/material.dart';

class FollowControls extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback onToggleFollow;
  final VoidCallback onStopPressed;

  const FollowControls({
    Key? key,
    required this.isFollowing,
    required this.onToggleFollow,
    required this.onStopPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: isFollowing ? Icons.person_off : Icons.person_search,
            label: isFollowing ? 'STOP FOLLOW' : 'FOLLOW ME',
            color: isFollowing ? Colors.orange : Colors.green,
            onPressed: onToggleFollow,
          ),
          _buildControlButton(
            icon: Icons.stop,
            label: 'STOP ROBOT',
            color: Colors.red,
            onPressed: onStopPressed,
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
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}