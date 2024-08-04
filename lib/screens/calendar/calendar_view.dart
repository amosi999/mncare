import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart' as sfcalendar;

import 'calendar_controller.dart';
import 'calendar_utils.dart';

class CalendarView extends StatelessWidget {
  final sfcalendar.CalendarController controller;
  final CalendarScreenController calendarScreenController;
  final Function(sfcalendar.ViewChangedDetails) onViewChanged;
  final Function(sfcalendar.CalendarTapDetails) onTap;

  const CalendarView({
    super.key,
    required this.controller,
    required this.calendarScreenController,
    required this.onViewChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return sfcalendar.SfCalendar(
      view: sfcalendar.CalendarView.month,
      controller: controller,
      //dataSource: calendarScreenController.getFilteredCalendarDataSource(),
      monthViewSettings: getMonthViewSettings(),
      headerHeight: 0,
      viewHeaderHeight: 40,
      viewHeaderStyle: getViewHeaderStyle(),
      todayHighlightColor: const Color.fromARGB(255, 235, 91, 0),
      cellBorderColor: Colors.grey[300],
      onViewChanged: onViewChanged,
      selectionDecoration: getSelectionDecoration(),
      onTap: onTap,
    );
  }
}
