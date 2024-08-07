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

  void setSelectedPet(Pet? pet) {
    _selectedPet = pet;
    _fetchAppointments(); // 선택한 펫의 일정 불러오기
    notifyListeners();
  }

  // Future<void> _fetchAppointments() async {
  //   if (_selectedPet == null) return;
  //   User? user = FirebaseAuth.instance.currentUser;
  //   if (user == null) return;

  //   final querySnapshot = await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(user.uid)
  //       .collection('pets')
  //       .doc(_selectedPet!.id)
  //       .collection('appointments')
  //       .get();

  //   _appointments.clear();
  //   for (var doc in querySnapshot.docs) {
  //     final data = doc.data();
  //     final pet = _selectedPet!;
  //     final type = _scheduleTypes.firstWhere(
  //       (t) => t.name == data['type'],
  //       orElse: () => _scheduleTypes.first,
  //     );

  //     final scheduleInfo = ScheduleInfo(
  //       id: doc.id,
  //       owner: pet,
  //       type: type,
  //       title: data['title'],
  //       date: DateTime.parse(data['date']),
  //       isAllDay: data['isAllDay'],
  //       startTime: data['startTime'] != null
  //           ? TimeOfDay(
  //               hour: int.parse(data['startTime'].split(':')[0]),
  //               minute: int.parse(data['startTime'].split(':')[1]),
  //             )
  //           : null,
  //       endTime: data['endTime'] != null
  //           ? TimeOfDay(
  //               hour: int.parse(data['endTime'].split(':')[0]),
  //               minute: int.parse(data['endTime'].split(':')[1]),
  //             )
  //           : null,
  //       description: data['description'],
  //     );

  //     _appointments.add(Appointment(
  //       id: scheduleInfo.id, // Firestore에서 가져온 고유 ID
  //       startTime: scheduleInfo.date,
  //       endTime: scheduleInfo.isAllDay
  //           ? DateTime(scheduleInfo.date.year, scheduleInfo.date.month,
  //               scheduleInfo.date.day, 23, 59, 59)
  //           : DateTime(
  //               scheduleInfo.date.year,
  //               scheduleInfo.date.month,
  //               scheduleInfo.date.day,
  //               scheduleInfo.endTime!.hour,
  //               scheduleInfo.endTime!.minute,
  //             ),
  //       subject: scheduleInfo.title,
  //       color: scheduleInfo.type.color,
  //       isAllDay: scheduleInfo.isAllDay,
  //       notes: "${scheduleInfo.description ?? ''}\n${scheduleInfo.owner.name}",
  //     ));
  //   }
  //   notifyListeners();
  // }

  Future<void> _fetchAppointments() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _appointments.clear();

    QuerySnapshot querySnapshot;
    //전체 선택시에
    if (_selectedPet == null) {
      querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('pets')
          .get();

      List<Pet> allPets = querySnapshot.docs
          .map((doc) => Pet(id: doc.id, name: doc['petName']))
          .toList();
      print('전체 allpets 들어가 있는 펫 ${allPets.length}');

      _appointments.clear();
      for (Pet pet in allPets) {
        QuerySnapshot petAppointments = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('pets')
            .doc(pet.id)
            .collection('appointments')
            .get();
        print('전체에 들어가 있는 펫 ${pet.name}');

        //각 펫의 일정을 불러와서 _appointments에 추가
        for (var doc in petAppointments.docs) {
          //print('전체에 일정 :  ${doc.id}}');
          final data = doc.data() as Map<String, dynamic>;
          if (data == null) continue;
          final type = _scheduleTypes.firstWhere(
            (t) => t.name == data['type'],
            orElse: () => _scheduleTypes.first,
          );

          final scheduleInfo = ScheduleInfo(
            id: doc.id,
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
            id: scheduleInfo.id,
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
            notes:
                "${scheduleInfo.description ?? ''}\n${scheduleInfo.owner.name}\n${scheduleInfo.owner.id}",
          ));
        }
      }
    } else {
      querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('pets')
          .doc(_selectedPet!.id)
          .collection('appointments')
          .get();

      _appointments.clear();
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data == null) continue; // Null 체크 추가
        final pet = _selectedPet!;
        final type = _scheduleTypes.firstWhere(
          (t) => t.name == data['type'],
          orElse: () => _scheduleTypes.first,
        );

        final scheduleInfo = ScheduleInfo(
          id: doc.id,
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
          id: scheduleInfo.id,
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
          notes:
              "${scheduleInfo.description ?? ''}\n${scheduleInfo.owner.name}\n${scheduleInfo.owner.id}",
        ));
      }
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
        .doc(schedule.owner.id) // _selectedPet 대신 schedule.owner를 사용
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

    final newSchedule = ScheduleInfo(
      id: docRef.id, // Firestore에서 생성된 고유 ID를 할당합니다.
      owner: schedule.owner,
      type: schedule.type,
      title: schedule.title,
      date: schedule.date,
      isAllDay: schedule.isAllDay,
      startTime: schedule.startTime,
      endTime: schedule.endTime,
      description: schedule.description,
    );

    _appointments.add(Appointment(
      id: newSchedule.id, // 고유 ID 추가 ..
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
      notes:
          "${schedule.description ?? ''}\n${schedule.owner.name}\n${schedule.owner.id}",
    ));

    print('스케줄 내용 : ${newSchedule}');
    notifyListeners();
  }

  void updateScheduleInCalendar(ScheduleInfo updatedSchedule) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('pets')
        .doc(updatedSchedule.owner.id)
        .collection('appointments')
        .doc(updatedSchedule.id);

    await docRef.update({
      'title': updatedSchedule.title,
      'type': updatedSchedule.type.name,
      'date': updatedSchedule.date.toIso8601String(),
      'isAllDay': updatedSchedule.isAllDay,
      'startTime': updatedSchedule.startTime != null
          ? '${updatedSchedule.startTime!.hour}:${updatedSchedule.startTime!.minute}'
          : null,
      'endTime': updatedSchedule.endTime != null
          ? '${updatedSchedule.endTime!.hour}:${updatedSchedule.endTime!.minute}'
          : null,
      'description': updatedSchedule.description,
    });

    int index = _appointments
        .indexWhere((appointment) => appointment.id == updatedSchedule.id);
    if (index != -1) {
      _appointments[index] = Appointment(
        id: updatedSchedule.id, // 고유 ID 유지
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
        notes:
            "${updatedSchedule.description ?? ''}\n${updatedSchedule.owner.name}\n${updatedSchedule.owner.id}",
      );
      notifyListeners();
    }
  }

  void deleteScheduleFromCalendar(String scheduleId, String petId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('pets')
        .doc(petId)
        .collection('appointments')
        .doc(scheduleId);

    await docRef.delete();

    _appointments.removeWhere((a) => a.id == scheduleId);
    notifyListeners();
  }

//appointment을 ScheduleInfo로 변환하는 로직 추가.
//왜..? 그냥 스케줄러를 불러오면 되는거 아닌가?
//왜.. appointment를 스케줄러 객체로 변환하는 수고를 해야하는 거지? 의도가 있나?
// ScheduleInfo appointmentToScheduleInfo(Appointment appointment) {
//   final notesParts = appointment.notes?.split('\n') ?? [];
//   final description = notesParts.isNotEmpty ? notesParts[0] : '';
//   final ownerName = notesParts.length > 1 ? notesParts[1] : '';

//   // 실제 펫 객체를 찾아 설정하는 로직 필요
//   final owner = _pets.firstWhere((pet) => pet.name == ownerName,
//       orElse: () => Pet(id: '', name: ''));

//   return ScheduleInfo(
//     id: appointment.id,
//     owner: owner,
//     type: _scheduleTypes.firstWhere((type) => type.color == appointment.color,
//         orElse: () => _scheduleTypes.first),
//     title: appointment.subject,
//     date: appointment.startTime,
//     isAllDay: appointment.isAllDay,
//     startTime: TimeOfDay.fromDateTime(appointment.startTime),
//     endTime: TimeOfDay.fromDateTime(appointment.endTime),
//     description: description,
//   );
// }
  Future<ScheduleInfo?> fetchScheduleById(String id, String petId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final petDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('pets')
        .doc(petId);

    final petDoc = await petDocRef.get();
    if (!petDoc.exists) return null;

    final petData = petDoc.data()!;
    final owner = Pet(id: petDoc.id, name: petData['petName']);

    final docRef = petDocRef.collection('appointments').doc(id);
    final doc = await docRef.get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    final type = _scheduleTypes.firstWhere((t) => t.name == data['type'],
        orElse: () => _scheduleTypes.first);

    return ScheduleInfo(
      id: doc.id,
      owner: owner,
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
  }

  // 일정 필터링 로직 추가
  List<Appointment> getFilteredAppointments() {
    if (_selectedPet == null) {
      return _appointments; // "전체"가 선택된 경우 모든 일정을 반환합니다.
    }
    return _appointments.where((appointment) {
      String ownerString = appointment.notes?.split('\n').last ?? '';
      print("전체 비교 : ${ownerString} == ${_selectedPet?.id}");
      return ownerString == _selectedPet?.id;
    }).toList();
  }

  MeetingDataSource getFilteredCalendarDataSource() {
    return MeetingDataSource(getFilteredAppointments());
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}
