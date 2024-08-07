import 'package:flutter/material.dart';
import 'package:mncare/screens/calendar/schedule_type_manager.dart';

//기존의 enum로직 삭제 후 Pet 클래스 추가
class Pet {
  final String id;
  final String name;

  Pet({required this.id, required this.name});
}

class ScheduleInfo {
  final String? id;
  final Pet owner;
  final ScheduleTypeInfo type;
  final String title;
  final DateTime date;
  final bool isAllDay;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final String? description;

  ScheduleInfo({
    this.id,
    required this.owner,
    required this.type,
    required this.title,
    required this.date,
    required this.isAllDay,
    this.startTime,
    this.endTime,
    this.description,
  });

  @override
  String toString() {
    return 'ScheduleInfo(id: $id, owner: ${owner.name}, type: ${type.name}, title: $title, date: $date, isAllDay: $isAllDay, startTime: $startTime, endTime: $endTime, description: $description)';
  }
}
