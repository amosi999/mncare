import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../screens/calendar/schedule_info.dart';
import '../screens/calendar/schedule_type_dialog.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final VoidCallback onMenuPressed;
  final Function(ScheduleOwner)? onCategorySelected; // nullable로 변경

  const TopAppBar({
    super.key,
    required this.selectedIndex,
    required this.onMenuPressed,
    this.onCategorySelected, // optional로 변경
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: selectedIndex == 1
          ? _buildDropdownMenu()
          : Text(AppConstants.appBarTitles[selectedIndex]),
      backgroundColor: Colors.grey[50],
      actions: [
        if (selectedIndex == 1)
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

  Widget _buildDropdownMenu() {
    return DropdownButton<ScheduleOwner>(
      value: ScheduleOwner.all,
      onChanged: (ScheduleOwner? newValue) {
        if (newValue != null) {
          onCategorySelected!(newValue);
        }
      },
      items: ScheduleOwner.values
          .map<DropdownMenuItem<ScheduleOwner>>((ScheduleOwner value) {
        return DropdownMenuItem<ScheduleOwner>(
          value: value,
          child: Text(scheduleOwnerToString(value)),
        );
      }).toList(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
