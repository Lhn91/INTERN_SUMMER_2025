import 'package:flutter/material.dart';

class TrackingStatusWidget extends StatelessWidget {
  final TrackingStatus status;

  const TrackingStatusWidget({
    Key? key,
    required this.status,
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
      child: Row(
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
    );
  }

  _StatusInfo _getStatusInfo() {
    switch (status) {
      case TrackingStatus.tracking:
        return _StatusInfo(
          Icons.person_search,
          Colors.green,
          'TRACKING',
        );
      case TrackingStatus.lost:
        return _StatusInfo(
          Icons.person_off,
          Colors.orange,
          'LOST TARGET',
        );
      case TrackingStatus.searching:
        return _StatusInfo(
          Icons.search,
          Colors.blue,
          'SEARCHING',
        );
    }
  }
}

class _StatusInfo {
  final IconData icon;
  final Color color;
  final String text;

  const _StatusInfo(this.icon, this.color, this.text);
}

enum TrackingStatus { tracking, lost, searching }
