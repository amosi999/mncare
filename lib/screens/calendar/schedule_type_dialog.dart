// schedule_type_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'schedule_type_manager.dart';

void showScheduleTypeDialog(BuildContext context) {
  final manager = ScheduleTypeManager();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('일정 종류 관리'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < manager.types.length; i++)
                    ListTile(
                      title: Text(manager.types[i].name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            color: manager.types[i].color,
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editType(context, i, setState),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                manager.removeType(i);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ElevatedButton(
                    child: const Text('새 종류 추가'),
                    onPressed: () => _addNewType(context, setState),
                  ),
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
        },
      );
    },
  );
}

void _editType(BuildContext context, int index, StateSetter setState) {
  final manager = ScheduleTypeManager();
  final currentType = manager.types[index];
  String name = currentType.name;
  Color color = currentType.color;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('일정 종류 수정'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: '이름'),
                onChanged: (value) => name = value,
                controller: TextEditingController(text: name),
              ),
              const SizedBox(height: 20),
              ColorPicker(
                pickerColor: color,
                onColorChanged: (Color value) => color = value,
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
            child: const Text('저장'),
            onPressed: () {
              setState(() {
                manager.updateType(index, name, color);
              });
              Navigator.of(context).pop();
            },
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 247, 247, 247),
      );
    },
  );
}

void _addNewType(BuildContext context, StateSetter setState) {
  final manager = ScheduleTypeManager();
  String name = '';
  Color color = Colors.blue;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('새 일정 종류 추가'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: '이름'),
                onChanged: (value) => name = value,
              ),
              const SizedBox(height: 20),
              ColorPicker(
                pickerColor: color,
                onColorChanged: (Color value) => color = value,
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
            child: const Text('추가'),
            onPressed: () {
              if (name.isNotEmpty) {
                setState(() {
                  manager.addType(name, color);
                });
                Navigator.of(context).pop();
              }
            },
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 247, 247, 247),
      );
    },
  );
}
