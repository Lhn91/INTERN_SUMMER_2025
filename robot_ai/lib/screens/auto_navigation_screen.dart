import 'package:flutter/material.dart';
import 'package:robot_ai/features/main/auto_navigation/auto_navigation_repository.dart';
import 'package:robot_ai/features/main/auto_navigation/data/models/route_data.dart';

class AutoNavigationScreen extends StatelessWidget {
  final List<RouteData> learnedRoutes;
  const AutoNavigationScreen({
    super.key,
    this.learnedRoutes = const [],
  });

  @override
  Widget build(BuildContext context) {
    return AutoNavigationPage(
      learnedRoutes: [],
    );
  }
}
