import 'package:flutter/material.dart';
import 'package:robot_ai/core/constants/colors.dart';

class RobotBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const RobotBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: AppColors.darkBackground,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.control_camera),
          label: 'Manual',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_pin_circle),
          label: 'Follow',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Auto',
        ),
      ],
    );
  }
}
