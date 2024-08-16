// schedule_type_manager.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  // 초기 데이터 여기 수정해야 함
  // final List<ScheduleTypeInfo> _types = [
  //   ScheduleTypeInfo('접종', Colors.green),
  //   ScheduleTypeInfo('내원', Colors.blue),
  // ];
  final List<ScheduleTypeInfo> _types = [];

  List<ScheduleTypeInfo> get types => _types;

//유저가 가지고 있는 카테고리를 가져오는 함수, 싱글톤으로 만들어서 어디서든 사용 가능
  Future<void> fetchTypesFromFirestore() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final CollectionReference categoriesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('categories');

    final QuerySnapshot snapshot = await categoriesRef.get();
    _types.clear();
    for (var doc in snapshot.docs) {
      _types.add(ScheduleTypeInfo(
        doc['name'],
        Color(doc['color']),
      ));
    }
  }

  Future<void> addType(String name, Color color) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final CollectionReference categoriesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('categories');

    final newDoc = await categoriesRef.add({
      'name': name,
      'color': color.value,
    });

    _types.add(ScheduleTypeInfo(name, color));
  }

  Future<void> removeType(int index) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final CollectionReference categoriesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('categories');

    final QuerySnapshot snapshot = await categoriesRef
        .where('name', isEqualTo: _types[index].name)
        .where('color', isEqualTo: _types[index].color.value)
        .get();

    for (var doc in snapshot.docs) {
      await categoriesRef.doc(doc.id).delete();
    }

    _types.removeAt(index);
  }

  Future<void> updateType(int index, String name, Color color) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final CollectionReference categoriesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('categories');

    final QuerySnapshot snapshot = await categoriesRef
        .where('name', isEqualTo: _types[index].name)
        .where('color', isEqualTo: _types[index].color.value)
        .get();

    for (var doc in snapshot.docs) {
      await categoriesRef.doc(doc.id).update({
        'name': name,
        'color': color.value,
      });
    }

    _types[index] = ScheduleTypeInfo(name, color);
  }
}