import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'appointment_dialog.dart';
import 'appointment_list_dialog.dart';
import 'calendar_controller.dart';
import 'calendar_view.dart' as custom_view;
import 'schedule_info.dart';
import 'schedule_type_manager.dart';

class CalendarScreen extends StatefulWidget {
  final CalendarScreenController controller;

  const CalendarScreen({super.key, required this.controller});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with AutomaticKeepAliveClientMixin<CalendarScreen> {
  bool _needsUpdate = false;
  final ScheduleTypeManager _scheduleTypeManager = ScheduleTypeManager();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_scheduleUpdate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.resetToToday();
    });
    _loadUserData(); // 사용자 정보를 로드하는 함수 호출
    _fetchScheduleTypes();
  }

  Future<void> _fetchScheduleTypes() async {
    await _scheduleTypeManager.fetchTypesFromFirestore();
    widget.controller.updateScheduleTypes(_scheduleTypeManager.types);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_scheduleUpdate);
    super.dispose();
  }

  //현재 User정보 불러 오는 코드.. 동시에 Pet의 정보도 받아와?
  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Firestore에서 사용자 데이터를 가져오거나, 필요에 따라 추가 작업을 수행합니다.
      print("스케줄러 User ID: ${user.uid}");
    }
  }

  void _scheduleUpdate() {
    if (!_needsUpdate) {
      _needsUpdate = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted && _needsUpdate) {
          setState(() {
            _needsUpdate = false;
          });
        }
      });
    }
  }

  void _onCalendarTapped(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.calendarCell) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AppointmentListDialog(
            date: details.date!,
            appointments:
                widget.controller.getAppointmentsForDate(details.date!),
            onEdit: _editAppointment,
            onDelete: _deleteAppointment,
          );
        },
      );
    }
  }

  void _editAppointment(Appointment appointment) async {
    final notesParts = appointment.notes?.split('\n') ?? [];
    final petId =
        notesParts.length > 2 ? notesParts[2] : ''; // 펫 ID를 notes에서 가져옴
    final scheduleInfo = await widget.controller
        .fetchScheduleById(appointment.id as String, petId);

    print(' 스케줄 수정 : ${scheduleInfo}');
    if (scheduleInfo != null) {
      showAppointmentDialog(
        context,
        (updatedSchedule) {
          try {
            widget.controller.updateScheduleInCalendar(updatedSchedule);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('일정 업데이트 중 오류가 발생했습니다: $e')),
            );
          }
        },
        initialSchedule: scheduleInfo,
      );
    }
  }

  void _deleteAppointment(Appointment appointment) {
    try {
      final notesParts = appointment.notes?.split('\n') ?? [];
      final petId =
          notesParts.length > 2 ? notesParts[2] : ''; // 펫 ID를 notes에서 가져옴

      widget.controller
          .deleteScheduleFromCalendar(appointment.id as String, petId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('일정 삭제 중 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 178, 0),
        title: GestureDetector(
          onTap: () async {
            bool updated =
                await widget.controller.showDatePickerDialog(context);
            if (updated) _scheduleUpdate();
          },
          child: Text(widget.controller.headerText),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            widget.controller.previousMonth();
            _scheduleUpdate();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              widget.controller.nextMonth();
              _scheduleUpdate();
            },
          ),
        ],
      ),
      //캘린더 요약 서비스를 보여주는 부분
      body: custom_view.CalendarView(
        controller: widget.controller.controller,
        calendarScreenController: widget.controller,
        onViewChanged: (ViewChangedDetails details) {
          widget.controller.onViewChanged(details);
          _scheduleUpdate();
        },
        onTap: _onCalendarTapped,
      ),
      floatingActionButton: SizedBox(
        width: 48,
        height: 48,
        child: FloatingActionButton(
          onPressed: () => showAppointmentDialog(
              context, widget.controller.addScheduleToCalendar),
          backgroundColor: const Color.fromARGB(255, 235, 91, 0),
          shape: const CircleBorder(),
          elevation: 1,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}