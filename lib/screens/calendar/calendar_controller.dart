import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'schedule_info.dart';
import 'schedule_type_manager.dart';

class CalendarScreenController extends ChangeNotifier {
  final CalendarController controller;
  final List<Appointment> _appointments = [];
  List<ScheduleTypeInfo> _scheduleTypes = [];
  late String _headerText;
  Pet? _selectedPet;

  //타입의 업데이트를 반여하려면 필요하다.
  void updateScheduleTypes(List<ScheduleTypeInfo> types) {
    _scheduleTypes = types;
    notifyListeners();
  }

  CalendarScreenController(this.controller) {
    _updateHeaderText();
  }

  String get headerText => _headerText;
  List<ScheduleTypeInfo> get scheduleTypes => _scheduleTypes;

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


  void setSelectedPet(Pet pet) {
    _selectedPet = pet;
    _fetchAppointments(); // 선택한 펫의 일정 불러오기
    notifyListeners();
  }

Future<void> _fetchAppointments() async {
    if (_selectedPet == null) return;
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('pets')
        .doc(_selectedPet!.id)
        .collection('appointments')
        .get();

    _appointments.clear();
    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final pet = _selectedPet!;
      final type = _scheduleTypes.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => _scheduleTypes.first,
      );
      
      final scheduleInfo = ScheduleInfo(
        owner: pet,
        type: type,
        title: data['title'],
        date: DateTime.parse(data['date']),
        isAllDay: data['isAllDay'],
        startTime: data['startTime'] != null
            ? TimeOfDay(
                hour: int.parse(data['startTime'].split(':')[0]),
                minute: int.parse(data['startTime'].split(':')[1]),
              )
            : null,
        endTime: data['endTime'] != null
            ? TimeOfDay(
                hour: int.parse(data['endTime'].split(':')[0]),
                minute: int.parse(data['endTime'].split(':')[1]),
              )
            : null,
        description: data['description'],
      );
      
      _appointments.add(Appointment(
        startTime: scheduleInfo.date,
        endTime: scheduleInfo.isAllDay
            ? DateTime(scheduleInfo.date.year, scheduleInfo.date.month,
                scheduleInfo.date.day, 23, 59, 59)
            : DateTime(
                scheduleInfo.date.year,
                scheduleInfo.date.month,
                scheduleInfo.date.day,
                scheduleInfo.endTime!.hour,
                scheduleInfo.endTime!.minute,
              ),
        subject: scheduleInfo.title,
        color: scheduleInfo.type.color,
        isAllDay: scheduleInfo.isAllDay,
        notes: "${scheduleInfo.description ?? ''}\n${scheduleInfo.owner.name}",
      ));
    }
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

  //firebase에 일정 추가하는 로직 추가.
  void addScheduleToCalendar(ScheduleInfo schedule) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final DocumentReference docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('pets')
        .doc(schedule.owner.id)
        .collection('appointments')
        .doc();

    await docRef.set({
      'title': schedule.title,
      'type': schedule.type.name,
      'date': schedule.date.toIso8601String(),
      'isAllDay': schedule.isAllDay,
      'startTime': schedule.startTime != null
          ? '${schedule.startTime!.hour}:${schedule.startTime!.minute}'
          : null,
      'endTime': schedule.endTime != null
          ? '${schedule.endTime!.hour}:${schedule.endTime!.minute}'
          : null,
      'description': schedule.description,
    });

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
      notes: "${schedule.description ?? ''}\n${schedule.owner.name}",
    ));
    notifyListeners();
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
        notes: "${updatedSchedule.description ?? ''}\n${updatedSchedule.owner.name}",
      );
      notifyListeners();
    }
  }

  void deleteScheduleFromCalendar(Appointment appointment) {
    _appointments.remove(appointment);
    notifyListeners();
  }

  ScheduleTypeInfo getScheduleTypeFromColor(Color color) {
    return _scheduleTypes.firstWhere(
          (type) => type.color == color,
          orElse: () => _scheduleTypes.first,
        );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}