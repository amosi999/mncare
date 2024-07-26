import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'schedule_info.dart';
import 'schedule_type_manager.dart';

void showAppointmentDialog(
  BuildContext context,
  Function(ScheduleInfo) onSaveSchedule, {
  ScheduleInfo? initialSchedule,
}) {
  final bool isEditing = initialSchedule != null;
  ScheduleOwner owner = initialSchedule?.owner ?? ScheduleOwner.all;
  ScheduleTypeInfo? type = initialSchedule?.type;
  String title = initialSchedule?.title ?? '';
  DateTime date = initialSchedule?.date ?? DateTime.now();
  bool isAllDay = initialSchedule?.isAllDay ?? false;
  TimeOfDay? startTime = initialSchedule?.startTime;
  TimeOfDay? endTime = initialSchedule?.endTime;
  String? description = initialSchedule?.description;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(isEditing ? '일정 수정' : '새 일정 추가'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<ScheduleOwner>(
                    value: owner,
                    onChanged: (ScheduleOwner? value) {
                      setState(() => owner = value!);
                    },
                    items: ScheduleOwner.values.map((ScheduleOwner ownerValue) {
                      return DropdownMenuItem<ScheduleOwner>(
                        value: ownerValue,
                        child: Text(scheduleOwnerToString(ownerValue)),
                      );
                    }).toList(),
                    decoration: const InputDecoration(labelText: '누구의 일정'),
                  ),
                  DropdownButtonFormField<ScheduleTypeInfo>(
                    value: type,
                    onChanged: (ScheduleTypeInfo? value) {
                      setState(() => type = value);
                    },
                    items: ScheduleTypeManager()
                        .types
                        .map((ScheduleTypeInfo type) {
                      return DropdownMenuItem<ScheduleTypeInfo>(
                        value: type,
                        child: Text(type.name),
                      );
                    }).toList(),
                    decoration: const InputDecoration(labelText: '일정 종류'),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: '제목'),
                    initialValue: title,
                    onChanged: (value) => title = value,
                  ),
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) setState(() => date = picked);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: '날짜'),
                      child: Text(DateFormat('yyyy-MM-dd').format(date)),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('하루 종일'),
                    value: isAllDay,
                    onChanged: (bool value) {
                      setState(() => isAllDay = value);
                    },
                  ),
                  if (!isAllDay) ...[
                    InkWell(
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: startTime ?? TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setState(() => startTime = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: '시작 시간'),
                        child: Text(startTime?.format(context) ?? '선택하세요'),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: endTime ?? TimeOfDay.now(),
                        );
                        if (picked != null) setState(() => endTime = picked);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: '종료 시간'),
                        child: Text(endTime?.format(context) ?? '선택하세요'),
                      ),
                    ),
                  ],
                  TextFormField(
                    decoration: const InputDecoration(labelText: '내용 (선택사항)'),
                    initialValue: description,
                    onChanged: (value) => description = value,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('취소'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text(isEditing ? '수정' : '추가'),
                onPressed: () {
                  if (type != null && title.isNotEmpty) {
                    ScheduleInfo schedule = ScheduleInfo(
                      owner: owner,
                      type: type!,
                      title: title,
                      date: date,
                      isAllDay: isAllDay,
                      startTime: startTime,
                      endTime: endTime,
                      description: description,
                    );
                    onSaveSchedule(schedule);
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('필수 정보를 모두 입력해주세요.')),
                    );
                  }
                },
              ),
            ],
            backgroundColor: const Color.fromARGB(255, 247, 247, 247),
          );
        },
      );
    },
  );
}
