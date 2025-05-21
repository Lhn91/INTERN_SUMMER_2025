import 'package:flutter/material.dart';
import 'package:robot_ai/core/constants/colors.dart';
import 'package:robot_ai/core/widgets/connection_status.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showConnectionStatus;
  final List<Widget>? actions;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showConnectionStatus = false,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Text(title),
          if (showConnectionStatus) ...[
            SizedBox(width: 12),
            ConnectionStatusWidget(
              type: ConnectionType.bluetooth,
              isConnected: true,
              strength: 85,
            ),
          ],
        ],
      ),
      backgroundColor: AppColors.darkBackground,
      elevation: 0,
      actions: [
        if (actions != null) ...actions!,
        IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            // Mở drawer hoặc menu
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
