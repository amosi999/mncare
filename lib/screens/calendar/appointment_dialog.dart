import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  Pet? owner = initialSchedule?.owner;
  ScheduleTypeInfo? type = initialSchedule?.type;
  String title = initialSchedule?.title ?? '';
  DateTime date = initialSchedule?.date ?? DateTime.now();
  bool isAllDay = initialSchedule?.isAllDay ?? false;
  TimeOfDay? startTime = initialSchedule?.startTime;
  TimeOfDay? endTime = initialSchedule?.endTime;
  String? description = initialSchedule?.description;
  List<Pet>? _pets;
  Pet? _selectedPet = owner;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          if (_pets == null) {
            _fetchPets().then((pets) {
              setState(() {
                _pets = pets;
              });
            });
          }

          return AlertDialog(
            title: Text(isEditing ? '일정 수정' : '새 일정 추가'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //if (_pets == null)
                  //FutureBuilder<List<Pet>>(
                  //future: _fetchPets(),
                  //builder: (context, snapshot) {
                  // if (snapshot.connectionState ==
                  //     ConnectionState.waiting) {
                  //   return const CircularProgressIndicator();
                  // }
                  // if (snapshot.hasError) {
                  //   return Text('Error: ${snapshot.error}');
                  // }
                  // if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  //   return const Text('No pets found.');
                  // }
                  if (_pets == null)
                    const CircularProgressIndicator()
                  else if (_pets!.isEmpty)
                    const Text('No pets found.')
                  else
                    _buildPetDropdown(_pets!, _selectedPet, (Pet? newValue) {
                      setState(() {
                        _selectedPet = newValue;
                        owner = newValue;
                      });
                      print("Selected owner value: ${owner?.name}");
                    }),

                  // _pets = snapshot.data!;

                  //     return _buildPetDropdown(_pets!, _selectedPet,
                  //         (Pet? newValue) {
                  //       setState(() {
                  //         _selectedPet = newValue;
                  //         owner = newValue;
                  //       });
                  //       print("Selected owner value: ${owner?.name}");
                  //     });
                  //   },
                  // ),
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
                  if (type != null &&
                      title.isNotEmpty &&
                      _selectedPet != null) {
                    ScheduleInfo schedule = ScheduleInfo(
                      owner: _selectedPet!,
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

Widget _buildPetDropdown(
    List<Pet> pets, Pet? selectedPet, ValueChanged<Pet?> onChanged) {
  return DropdownButtonFormField<Pet>(
    value: selectedPet,
    onChanged: onChanged,
    items: pets.map((Pet pet) {
      return DropdownMenuItem<Pet>(
        value: pet,
        child: Text(pet.name),
      );
    }).toList(),
    decoration: const InputDecoration(labelText: '누구의 일정'),
  );
}

Future<List<Pet>> _fetchPets() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print("User not logged in");
    return [];
  }
  final querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('pets')
      .get();

  print("Pets fetched: ${querySnapshot.docs.length}");

  return querySnapshot.docs
      .map((doc) => Pet(id: doc.id, name: doc['petName']))
      .toList();
}
