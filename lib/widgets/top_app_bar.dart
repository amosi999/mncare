import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../screens/calendar/schedule_type_dialog.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final VoidCallback onMenuPressed;

  const TopAppBar({
    super.key,
    required this.selectedIndex,
    required this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(AppConstants.appBarTitles[selectedIndex]),
      backgroundColor: Colors.grey[50],
      actions: [
        // 캘린더 화면에서만 일정 종류 관리 버튼을 표시합니다
        if (selectedIndex == 1) // 캘린더 탭의 인덱스가 1이라고 가정합니다
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () => showScheduleTypeDialog(context),
          ),
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: onMenuPressed,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
