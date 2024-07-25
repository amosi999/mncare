import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'schedule_info.dart';
import 'schedule_type_manager.dart';

class CalendarScreenController extends ChangeNotifier {
  final CalendarController controller;
  final List<Appointment> _appointments = [];
  late String _headerText;
  ScheduleOwner _selectedCategory = ScheduleOwner.all;

  CalendarScreenController(this.controller) {
    _updateHeaderText();
  }

  String get headerText => _headerText;
  ScheduleOwner get selectedCategory => _selectedCategory;

  void _updateHeaderText() {
    DateTime displayDate = controller.displayDate ?? DateTime.now();
    _headerText = DateFormat('MMMM yyyy').format(displayDate);
  }

  void updateHeaderText() {
    _updateHeaderText();
    notifyListeners();
  }

  void resetToToday() {
    controller.displayDate = DateTime.now();
    updateHeaderText();
  }

  Future<bool> showDatePickerDialog(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.displayDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != controller.displayDate) {
      controller.displayDate = picked;
      updateHeaderText();
      return true;
    }
    return false;
  }

  void previousMonth() {
    controller.backward!();
    updateHeaderText();
  }

  void nextMonth() {
    controller.forward!();
    updateHeaderText();
  }

  void onViewChanged(ViewChangedDetails details) {
    if (details.visibleDates.isNotEmpty) {
      updateHeaderText();
    }
  }

  MeetingDataSource getCalendarDataSource() {
    return MeetingDataSource(_appointments);
  }

  void setSelectedCategory(ScheduleOwner category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();
    }
  }

  List<Appointment> getFilteredAppointments() {
    if (_selectedCategory == ScheduleOwner.all) {
      return _appointments;
    }
    return _appointments.where((appointment) {
      String ownerString = appointment.notes?.split('\n').last ?? '';
      return ownerString == _selectedCategory.toString();
    }).toList();
  }

  MeetingDataSource getFilteredCalendarDataSource() {
    return MeetingDataSource(getFilteredAppointments());
  }

  void addScheduleToCalendar(ScheduleInfo schedule) {
    _appointments.add(Appointment(
      startTime: schedule.isAllDay
          ? DateTime(schedule.date.year, schedule.date.month, schedule.date.day)
          : DateTime(
              schedule.date.year,
              schedule.date.month,
              schedule.date.day,
              schedule.startTime!.hour,
              schedule.startTime!.minute,
            ),
      endTime: schedule.isAllDay
          ? DateTime(schedule.date.year, schedule.date.month, schedule.date.day,
              23, 59, 59)
          : DateTime(
              schedule.date.year,
              schedule.date.month,
              schedule.date.day,
              schedule.endTime!.hour,
              schedule.endTime!.minute,
            ),
      subject: schedule.title,
      color: schedule.type.color,
      isAllDay: schedule.isAllDay,
      notes: "${schedule.description ?? ''}\n${schedule.owner}",
    ));
    notifyListeners();
  }

  List<Appointment> getAppointmentsForDate(DateTime date) {
    return _appointments
        .where((appointment) =>
            appointment.startTime.year == date.year &&
            appointment.startTime.month == date.month &&
            appointment.startTime.day == date.day)
        .toList();
  }

  void updateScheduleInCalendar(
      Appointment oldAppointment, ScheduleInfo updatedSchedule) {
    int index = _appointments
        .indexWhere((appointment) => appointment == oldAppointment);
    if (index != -1) {
      _appointments[index] = Appointment(
        startTime: updatedSchedule.isAllDay
            ? updatedSchedule.date
            : DateTime(
                updatedSchedule.date.year,
                updatedSchedule.date.month,
                updatedSchedule.date.day,
                updatedSchedule.startTime!.hour,
                updatedSchedule.startTime!.minute,
              ),
        endTime: updatedSchedule.isAllDay
            ? DateTime(updatedSchedule.date.year, updatedSchedule.date.month,
                updatedSchedule.date.day, 23, 59, 59)
            : DateTime(
                updatedSchedule.date.year,
                updatedSchedule.date.month,
                updatedSchedule.date.day,
                updatedSchedule.endTime!.hour,
                updatedSchedule.endTime!.minute,
              ),
        subject: updatedSchedule.title,
        color: updatedSchedule.type.color,
        isAllDay: updatedSchedule.isAllDay,
        notes: updatedSchedule.description,
      );
      notifyListeners();
    }
  }

  void deleteScheduleFromCalendar(Appointment appointment) {
    _appointments.remove(appointment);
    notifyListeners();
  }

  ScheduleTypeInfo getScheduleTypeFromColor(Color color) {
    return ScheduleTypeManager().types.firstWhere(
          (type) => type.color == color,
          orElse: () => ScheduleTypeManager().types.first,
        );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}
