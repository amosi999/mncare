import 'package:flutter/material.dart';
import 'package:mncare/screens/calendar/schedule_type_manager.dart';

enum ScheduleOwner { all, meru, darae }

enum ScheduleType { vaccination, visit }

class ScheduleInfo {
  final ScheduleOwner owner;
  final ScheduleTypeInfo type;
  final String title;
  final DateTime date;
  final bool isAllDay;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final String? description;

  ScheduleInfo({
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
    return 'ScheduleInfo(owner: $owner, type: $type, title: $title, date: $date, isAllDay: $isAllDay, startTime: $startTime, endTime: $endTime, description: $description)';
  }
}

// 유틸리티 함수들
String scheduleOwnerToString(ScheduleOwner owner) {
  switch (owner) {
    case ScheduleOwner.all:
      return '전체';
    case ScheduleOwner.meru:
      return '머루';
    case ScheduleOwner.darae:
      return '다래';
  }
}

String scheduleTypeToString(ScheduleType type) {
  switch (type) {
    case ScheduleType.vaccination:
      return '접종';
    case ScheduleType.visit:
      return '내원';
  }
}
