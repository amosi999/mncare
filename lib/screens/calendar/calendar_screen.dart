import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'appointment_dialog.dart';
import 'appointment_list_dialog.dart';
import 'calendar_controller.dart';
import 'calendar_view.dart' as custom_view;
import 'schedule_info.dart';

class CalendarScreen extends StatefulWidget {
  final CalendarScreenController controller;

  const CalendarScreen({super.key, required this.controller});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with AutomaticKeepAliveClientMixin<CalendarScreen> {
  bool _needsUpdate = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_scheduleUpdate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.resetToToday();
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_scheduleUpdate);
    super.dispose();
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

  void _editAppointment(Appointment appointment) {
    ScheduleInfo scheduleInfo =
        widget.controller.appointmentToScheduleInfo(appointment);

    showAppointmentDialog(
      context,
      (updatedSchedule) {
        try {
          widget.controller
              .updateScheduleInCalendar(appointment, updatedSchedule);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('일정 업데이트 중 오류가 발생했습니다: $e')),
          );
        }
      },
      initialSchedule: scheduleInfo,
    );
  }

  void _deleteAppointment(Appointment appointment) {
    try {
      widget.controller.deleteScheduleFromCalendar(appointment);
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
