import 'package:flutter/material.dart';

class MapControls extends StatelessWidget {
  final bool hasDestination;
  final VoidCallback onNavigatePressed;
  final VoidCallback onSendRoutePressed;
  final bool isNavigating;

  const MapControls({
    Key? key,
    required this.hasDestination,
    required this.onNavigatePressed,
    required this.onSendRoutePressed,
    this.isNavigating = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildControlButton(
            icon: Icons.navigation,
            label: 'GO TO',
            color: Colors.green,
            onPressed: hasDestination ? onNavigatePressed : null,
            isActive: hasDestination && !isNavigating,
          ),
          _buildControlButton(
            icon: Icons.send,
            label: 'SEND ROUTE',
            color: Colors.blue,
            onPressed: onSendRoutePressed,
            isActive: !isNavigating,
          ),
          if (isNavigating)
            _buildControlButton(
              icon: Icons.stop,
              label: 'STOP',
              color: Colors.red,
              onPressed: () {
                // Handle stop navigation
                onNavigatePressed();
              },
              isActive: true,
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
    required bool isActive,
  }) {
    return Opacity(
      opacity: isActive ? 1.0 : 0.5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(icon),
            color: color,
            onPressed: isActive ? onPressed : null,
          ),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
