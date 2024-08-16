import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'schedule_type_manager.dart';

MonthViewSettings getMonthViewSettings() {
  return const MonthViewSettings(
    appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
    monthCellStyle: MonthCellStyle(
      textStyle: TextStyle(color: Colors.black),
      trailingDatesTextStyle: TextStyle(color: Colors.grey),
      trailingDatesBackgroundColor: Color.fromARGB(255, 240, 240, 240),
      leadingDatesTextStyle: TextStyle(color: Colors.grey),
      leadingDatesBackgroundColor: Color.fromARGB(255, 240, 240, 240),
      backgroundColor: Colors.white,
      todayBackgroundColor: Colors.white,
    ),
  );
}

ViewHeaderStyle getViewHeaderStyle() {
  return const ViewHeaderStyle(
    backgroundColor: Colors.white,
    dayTextStyle: TextStyle(color: Colors.black),
  );
}

BoxDecoration getSelectionDecoration() {
  return BoxDecoration(
    border: Border.all(color: const Color.fromARGB(255, 235, 91, 0), width: 2),
    borderRadius: BorderRadius.circular(4),
  );
}

Color getScheduleColor(ScheduleTypeInfo type) {
  return type.color;
}