import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late CalendarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CalendarController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[100],
        title: GestureDetector(
          onTap: _showDatePicker,
          child: Text(_getHeaderText()),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _previousMonth,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextMonth,
          ),
        ],
      ),
      body: SfCalendar(
        view: CalendarView.month,
        controller: _controller,
        dataSource: _getCalendarDataSource(),
        monthViewSettings: const MonthViewSettings(
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
        ),
        headerHeight: 0,
        viewHeaderHeight: 40,
        onViewChanged: (ViewChangedDetails details) {
          if (details.visibleDates.isNotEmpty) {
            _updateHeaderText();
          }
        },
      ),
    );
  }

  String _getHeaderText() {
    DateTime? displayDate = _controller.displayDate ?? DateTime.now();
    return DateFormat('MMMM yyyy').format(displayDate);
  }

  void _updateHeaderText() {
    Future.microtask(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _previousMonth() {
    _controller.backward!();
  }

  void _nextMonth() {
    _controller.forward!();
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _controller.displayDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _controller.displayDate) {
      setState(() {
        _controller.displayDate = picked;
      });
    }
  }

  MeetingDataSource _getCalendarDataSource() {
    List<Appointment> appointments = <Appointment>[];
    appointments.add(Appointment(
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 2)),
      subject: '미팅',
      color: Colors.blue,
    ));
    return MeetingDataSource(appointments);
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}