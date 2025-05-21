import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:robot_ai/screens/auto_navigation_screen.dart';
import 'package:robot_ai/screens/follow_human_screen.dart';
import 'package:robot_ai/screens/manual_control_screen.dart';

class MainNavigationScreen extends HookWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentIndex = useState(0);

    final screens = [
      const ManualControlScreen(),
      const FollowHumanScreen(),
      const AutoNavigationScreen(),
    ];

    return Scaffold(
      body: screens[currentIndex.value],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex.value,
        onTap: (index) => currentIndex.value = index,
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