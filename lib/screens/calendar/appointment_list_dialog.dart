import 'package:flutter/material.dart';
import 'package:mncare/screens/calendar/schedule_info.dart';
import 'package:mncare/screens/calendar/schedule_type_manager.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'appointment_detail_dialog.dart';

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

  ScheduleInfo _appointmentToScheduleInfo(Appointment appointment) {
    Pet owner = Pet(id: '', name: ''); // 기본값을 빈 Pet 객체로 설정
    String ownerString = appointment.notes?.split('\n').last ?? '';
    // 실제 펫 객체를 찾아 설정하는 로직 필요

    return ScheduleInfo(
      owner: owner,
      type: ScheduleTypeManager().types.firstWhere(
            (type) => type.color == appointment.color,
            orElse: () => ScheduleTypeManager().types.first,
          ),
      title: appointment.subject,
      date: appointment.startTime,
      isAllDay: appointment.isAllDay,
      startTime: TimeOfDay.fromDateTime(appointment.startTime),
      endTime: TimeOfDay.fromDateTime(appointment.endTime),
      description: appointment.notes?.split('\n').first,
    );
  }

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
                  final schedule = _appointmentToScheduleInfo(appointment);
                  return InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AppointmentDetailDialog(schedule: schedule);
                        },
                      );
                    },
                    child: ListTile(
                      title: RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            TextSpan(
                              text:
                                  '[${schedule.owner.name}/${schedule.type.name}] ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: schedule.type.color,
                              ),
                            ),
                            TextSpan(text: schedule.title),
                          ],
                        ),
                      ),
                      subtitle: Text(schedule.isAllDay
                          ? '하루 종일'
                          : '${schedule.startTime?.format(context)} - ${schedule.endTime?.format(context)}'),
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
