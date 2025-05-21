import 'package:flutter/material.dart';
import 'package:robot_ai/features/main/auto_navigation/data/models/route_data.dart';
import 'package:robot_ai/features/main/auto_navigation/widgets/map_controls.dart';

class AutoNavigationPage extends StatefulWidget {
  final List<RouteData> learnedRoutes;

  const AutoNavigationPage({
    Key? key,
    required this.learnedRoutes,
  }) : super(key: key);

  @override
  State<AutoNavigationPage> createState() => _AutoNavigationPageState();
}

class _AutoNavigationPageState extends State<AutoNavigationPage> {
  Offset? _selectedPosition;
  bool _isNavigating = false;
  RouteData? _selectedRoute;

  bool get _hasDestination => _selectedPosition != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Navigation'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            // Map view
            _buildMapView(),

            // Mini camera preview
            Positioned(
              top: 80,
              right: 20,
              child: _buildMiniCameraPreview(),
            ),

            // Controls
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: MapControls(
                hasDestination: _hasDestination,
                isNavigating: _isNavigating,
                onNavigatePressed: _toggleNavigation,
                onSendRoutePressed: _sendRouteToRobot,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return GestureDetector(
      onTapDown: (details) {
        final renderBox = context.findRenderObject() as RenderBox;
        final localPosition = renderBox.globalToLocal(details.globalPosition);
        setState(() {
          _selectedPosition = localPosition;
          _isNavigating = false;
        });
      },
      child: CustomPaint(
        size: Size.infinite,
        painter: _MapPainter(
          selectedPosition: _selectedPosition,
          selectedRoute: _selectedRoute,
          learnedRoutes: widget.learnedRoutes,
        ),
      ),
    );
  }

  Widget _buildMiniCameraPreview() {
    return Container(
      width: 100,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white30),
      ),
      child: const Center(
        child: Icon(Icons.videocam, color: Colors.white),
      ),
    );
  }

  void _toggleNavigation() {
    if (!_hasDestination) return;

    setState(() {
      _isNavigating = !_isNavigating;
    });

    if (_isNavigating) {
      _startNavigation();
    } else {
      _stopNavigation();
    }
  }

  void _startNavigation() {
    debugPrint('Starting navigation to $_selectedPosition');
    // Implement actual navigation start logic
  }

  void _stopNavigation() {
    debugPrint('Stopping navigation');
    // Implement actual navigation stop logic
  }

  void _sendRouteToRobot() {
    if (_selectedRoute != null) {
      debugPrint('Sending route: ${_selectedRoute!.name}');
      // Implement actual route sending logic
    }
  }
}

class _MapPainter extends CustomPainter {
  final Offset? selectedPosition;
  final RouteData? selectedRoute;
  final List<RouteData> learnedRoutes;

  _MapPainter({
    required this.selectedPosition,
    required this.selectedRoute,
    required this.learnedRoutes,
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

    // Draw all learned routes
    for (final route in learnedRoutes) {
      if (route.points.isEmpty) continue;

      final isSelected = selectedRoute?.name == route.name;
      final routePaint = Paint()
        ..color = isSelected ? Colors.orange : Colors.blue.withOpacity(0.5)
        ..strokeWidth = isSelected ? 4.0 : 2.0
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(route.points.first.dx, route.points.first.dy);

      for (final point in route.points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }

      canvas.drawPath(path, routePaint);
    }

    // Draw selected position
    if (selectedPosition != null) {
      final markerPaint = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.fill;

      canvas.drawCircle(selectedPosition!, 10, markerPaint);

      // Draw pulsing effect
      canvas.drawCircle(
        selectedPosition!,
        15,
        markerPaint..color = Colors.green.withOpacity(0.3),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
