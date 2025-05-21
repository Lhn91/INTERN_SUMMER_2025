// lib/data/models/route_data.dart
import 'dart:ui';

class RouteData {
  final List<Offset> points;
  final DateTime createdAt;
  final String? name;

  RouteData({
    required this.points,
    required this.createdAt,
    this.name,
  });

  // Helper method to create empty route
  factory RouteData.empty() => RouteData(
        points: [],
        createdAt: DateTime.now(),
      );

  // Convert to map for serialization
  Map<String, dynamic> toMap() => {
        'points': points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
        'createdAt': createdAt.toIso8601String(),
        'name': name,
      };

  // Create from map
  factory RouteData.fromMap(Map<String, dynamic> map) => RouteData(
        points: (map['points'] as List)
            .map((p) => Offset(p['x'] as double, p['y'] as double))
            .toList(),
        createdAt: DateTime.parse(map['createdAt'] as String),
        name: map['name'] as String?,
      );
}
