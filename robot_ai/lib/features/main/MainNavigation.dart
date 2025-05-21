import 'package:flutter/material.dart';
import 'package:robot_ai/screens/auto_navigation_screen.dart';
import 'package:robot_ai/screens/follow_human_screen.dart';
import 'package:robot_ai/screens/manual_control_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ManualControlScreen(),
    const FollowHumanScreen(),
    const AutoNavigationScreen(learnedRoutes: []),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.control_camera),
            label: 'Manual',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_search),
            label: 'Follow',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.navigation),
            label: 'Auto',
          ),
        ],
      ),
    );
  }
}
