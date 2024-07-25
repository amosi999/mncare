import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class AppointmentListDialog extends StatelessWidget {
  final DateTime date;
  final List<Appointment> appointments;
  final Function(Appointment) onEdit;
  final Function(Appointment) onDelete;

  const AppointmentListDialog({
    super.key,
    required this.date,
    required this.appointments,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
                            onEdit(appointment);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            onDelete(appointment);
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
      backgroundColor: const Color.fromARGB(255, 247, 247, 247),
    );
  }
}
