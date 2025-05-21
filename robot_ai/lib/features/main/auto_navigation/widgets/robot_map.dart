import 'package:flutter/material.dart';
import 'package:robot_ai/core/constants/colors.dart';
import 'package:robot_ai/features/main/auto_navigation/data/models/route_data.dart';

class RobotMap extends StatefulWidget {
  final List<RouteData> routes;
  final ValueChanged<Offset> onTap;
  final Offset? selectedPosition;

  const RobotMap({
    Key? key,
    required this.routes,
    required this.onTap,
    this.selectedPosition,
  }) : super(key: key);

  @override
  _RobotMapState createState() => _RobotMapState();
}

class _RobotMapState extends State<RobotMap> {
  final TransformationController _transformationController =
      TransformationController();
  late InteractiveViewer _interactiveViewer;

  @override
  void initState() {
    super.initState();
    _interactiveViewer = InteractiveViewer(
      transformationController: _transformationController,
      boundaryMargin: EdgeInsets.all(20),
      minScale: 0.1,
      maxScale: 4.0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onTapDown: (details) {
              final localPosition = _transformationController.toScene(
                details.localPosition,
              );
              widget.onTap(localPosition);
            },
            child: CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: MapPainter(
                routes: widget.routes,
                selectedPosition: widget.selectedPosition,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _interactiveViewer;
  }
}

class MapPainter extends CustomPainter {
  final List<RouteData> routes;
  final Offset? selectedPosition;

  MapPainter({
    required this.routes,
    this.selectedPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid background
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 0.5;

    const gridSize = 20.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw routes
    for (final route in routes) {
      if (route.points.isEmpty) continue;

      final pathPaint = Paint()
        ..color = AppColors.primary.withOpacity(0.7)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(route.points.first.dx, route.points.first.dy);

      for (final point in route.points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }

      canvas.drawPath(path, pathPaint);
    }

    // Draw selected position
    if (selectedPosition != null) {
      final markerPaint = Paint()
        ..color = AppColors.accent
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        selectedPosition!,
        10,
        markerPaint,
      );

      canvas.drawCircle(
        selectedPosition!,
        15,
        markerPaint..color = AppColors.accent.withOpacity(0.3),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
