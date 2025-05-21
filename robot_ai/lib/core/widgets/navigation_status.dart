import 'package:flutter/material.dart';

class NavigationStatusWidget extends StatelessWidget {
  final NavigationStatus status;
  final double progress;

  const NavigationStatusWidget({
    Key? key,
    required this.status,
    this.progress = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                statusInfo.icon,
                color: statusInfo.color,
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                statusInfo.text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (status == NavigationStatus.inProgress)
            Padding(
              padding: EdgeInsets.only(top: 4),
              child: SizedBox(
                width: 120,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(statusInfo.color),
                  minHeight: 6,
                ),
              ),
            ),
        ],
      ),
    );
  }

  _StatusInfo _getStatusInfo() {
    switch (status) {
      case NavigationStatus.inProgress:
        return _StatusInfo(
          Icons.navigation,
          Colors.green,
          'NAVIGATING',
        );
      case NavigationStatus.completed:
        return _StatusInfo(
          Icons.check_circle,
          Colors.blue,
          'COMPLETED',
        );
      case NavigationStatus.failed:
        return _StatusInfo(
          Icons.error,
          Colors.red,
          'FAILED',
        );
      case NavigationStatus.ready:
        return _StatusInfo(
          Icons.directions,
          Colors.orange,
          'READY',
        );
    }
  }
}

enum NavigationStatus { inProgress, completed, failed, ready }

class _StatusInfo {
  final IconData icon;
  final Color color;
  final String text;

  const _StatusInfo(this.icon, this.color, this.text);
}
