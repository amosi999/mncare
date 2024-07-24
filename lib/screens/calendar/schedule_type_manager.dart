// schedule_type_manager.dart
import 'package:flutter/material.dart';

class ScheduleTypeInfo {
  String name;
  Color color;

  ScheduleTypeInfo(this.name, this.color);
}

class ScheduleTypeManager {
  static final ScheduleTypeManager _instance = ScheduleTypeManager._internal();

  factory ScheduleTypeManager() {
    return _instance;
  }

  ScheduleTypeManager._internal();

  final List<ScheduleTypeInfo> _types = [
    ScheduleTypeInfo('접종', Colors.green),
    ScheduleTypeInfo('내원', Colors.blue),
  ];

  List<ScheduleTypeInfo> get types => _types;

  void addType(String name, Color color) {
    _types.add(ScheduleTypeInfo(name, color));
  }

  void removeType(int index) {
    if (index >= 0 && index < _types.length) {
      _types.removeAt(index);
    }
  }

  void updateType(int index, String name, Color color) {
    if (index >= 0 && index < _types.length) {
      _types[index] = ScheduleTypeInfo(name, color);
    }
  }
}
