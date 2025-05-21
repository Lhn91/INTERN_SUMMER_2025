import 'package:flutter/material.dart';

class HumanDetectionBox extends StatelessWidget {
  final bool isTracking;
  final Rect boundingBox;
  final Color color;

  const HumanDetectionBox({
    Key? key,
    required this.isTracking,
    required this.boundingBox,
    this.color = Colors.orange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isTracking) return SizedBox.shrink();

    return Positioned.fromRect(
      rect: boundingBox,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: color,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: EdgeInsets.all(4),
                color: color.withOpacity(0.7),
                child: Text(
                  'PERSON',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(4),
                color: color.withOpacity(0.7),
                child: Icon(
                  Icons.accessibility,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
