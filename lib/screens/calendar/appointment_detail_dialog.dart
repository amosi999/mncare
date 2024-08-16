import 'package:flutter/material.dart';
import 'package:mncare/screens/calendar/schedule_info.dart';

class AppointmentDetailDialog extends StatelessWidget {
  final ScheduleInfo schedule;

  const AppointmentDetailDialog({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    print('스케줄 상세보기 로드: $schedule');
    return AlertDialog(
      title: const Text('일정 상세 정보'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('제목: ${schedule.title}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
                '소유자: ${schedule.owner.name}'), //소유자의 이름울 출력 // 여기서는 Pet의 이름이겠지/
            const SizedBox(height: 8),
            Text('유형: ${schedule.type.name}'),
            const SizedBox(height: 8),
            Text(
                '날짜: ${schedule.date.year}년 ${schedule.date.month}월 ${schedule.date.day}일'),
            const SizedBox(height: 8),
            Text(schedule.isAllDay
                ? '하루 종일'
                : '시간: ${schedule.startTime?.format(context)} - ${schedule.endTime?.format(context)}'),
            const SizedBox(height: 8),
            Text('설명: ${schedule.description ?? "없음"}'),
          ],
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