import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'appointment_dialog.dart';
import 'calendar_controller.dart';
import 'calendar_utils.dart';
import 'schedule_info.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late CalendarController _controller;
  late CalendarScreenController _calendarScreenController;

  @override
  void initState() {
    super.initState();
    _controller = CalendarController();
    _calendarScreenController = CalendarScreenController(_controller);
    _calendarScreenController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _calendarScreenController.dispose();
    super.dispose();
  }

  void _onCalendarTapped(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.calendarCell) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return _buildAppointmentsDialog(details.date!);
        },
      );
    }
  }

  Widget _buildAppointmentsDialog(DateTime date) {
    List<Appointment> appointments =
        _calendarScreenController.getAppointmentsForDate(date);
    return AlertDialog(
      title: Text('${date.year}년 ${date.month}월 ${date.day}일 일정'),
      content: appointments.isEmpty
          ? const Text('이 날짜에 일정이 없습니다.')
          : SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
                  return ListTile(
                    title: Text(appointment.subject),
                    subtitle: Text(appointment.isAllDay
                        ? '하루 종일'
                        : '${appointment.startTime.hour}:${appointment.startTime.minute.toString().padLeft(2, '0')} - ${appointment.endTime.hour}:${appointment.endTime.minute.toString().padLeft(2, '0')}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.of(context).pop();
                            _editAppointment(appointment);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _deleteAppointment(appointment);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
      actions: <Widget>[
        TextButton(
          child: const Text('닫기'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  void _editAppointment(Appointment appointment) {
    // Convert Appointment to ScheduleInfo
    ScheduleInfo scheduleInfo = ScheduleInfo(
      owner: ScheduleOwner.all, // You might need to adjust this
      type:
          _calendarScreenController.getScheduleTypeFromColor(appointment.color),
      title: appointment.subject,
      date: appointment.startTime,
      isAllDay: appointment.isAllDay,
      startTime: TimeOfDay.fromDateTime(appointment.startTime),
      endTime: TimeOfDay.fromDateTime(appointment.endTime),
      description: appointment.notes,
    );

    showAppointmentDialog(
      context,
      (updatedSchedule) {
        _calendarScreenController.updateScheduleInCalendar(
            appointment, updatedSchedule);
        setState(() {});
      },
      initialSchedule: scheduleInfo,
    );
  }

  void _deleteAppointment(Appointment appointment) {
    _calendarScreenController.deleteScheduleFromCalendar(appointment);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 178, 0),
        title: GestureDetector(
          onTap: () => _calendarScreenController.showDatePickerDialog(context),
          child: Text(_calendarScreenController.getHeaderText()),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _calendarScreenController.previousMonth,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _calendarScreenController.nextMonth,
          ),
        ],
      ),
      body: SfCalendar(
        view: CalendarView.month,
        controller: _controller,
        dataSource: _calendarScreenController.getCalendarDataSource(),
        monthViewSettings: getMonthViewSettings(),
        headerHeight: 0,
        viewHeaderHeight: 40,
        viewHeaderStyle: getViewHeaderStyle(),
        todayHighlightColor: const Color.fromARGB(255, 235, 91, 0),
        cellBorderColor: Colors.grey[300],
        onViewChanged: (ViewChangedDetails details) {
          if (details.visibleDates.isNotEmpty) {
            _calendarScreenController.updateHeaderText();
          }
        },
        selectionDecoration: getSelectionDecoration(),
        onTap: _onCalendarTapped,
      ),
      floatingActionButton: SizedBox(
        width: 44,
        height: 44,
        child: FloatingActionButton(
          onPressed: () => showAppointmentDialog(
              context, _calendarScreenController.addScheduleToCalendar),
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
