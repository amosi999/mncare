// utils.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> saveWaterIntake({
  required DateTime date,
  required String petId,
}) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  String dateStr = date.toIso8601String().split('T').first;

  final trackingDocRef = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('pets')
      .doc(petId)
      .collection('tracking')
      .doc(dateStr);

  final docSnapshot = await trackingDocRef.get();

  if (!docSnapshot.exists) {
    print("해당 날짜의 트래킹 데이터가 존재하지 않습니다.");
    return;
  }

  int waterGoal = (docSnapshot.get('waterGoal') as num).toInt();
  int waterCount = (docSnapshot.get('waterCount') as num).toInt();

  int volume = waterGoal ~/ waterCount;

  final waterIntakeDocRef =
      trackingDocRef.collection('water').doc(); // 고유 ID로 회차 생성

  await waterIntakeDocRef.set({
    'volume': volume,
    'timestamp': FieldValue.serverTimestamp(), // 회차 생성 시간 기록
  });

  print("음수량 기록이 성공적으로 저장되었습니다. Volume: $volume ml");
}

// 사료량 저장 함수
Future<void> saveFoodIntake({
  required DateTime date,
  required String petId,
}) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  String dateStr = date.toIso8601String().split('T').first;

  final trackingDocRef = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('pets')
      .doc(petId)
      .collection('tracking')
      .doc(dateStr);

  final docSnapshot = await trackingDocRef.get();

  if (!docSnapshot.exists) {
    print("해당 날짜의 트래킹 데이터가 존재하지 않습니다.");
    return;
  }

  int foodGoal = (docSnapshot.get('foodGoal') as num).toInt();
  int foodCount = (docSnapshot.get('foodCount') as num).toInt();

  int volume = foodGoal ~/ foodCount;

  final foodIntakeDocRef =
      trackingDocRef.collection('food').doc(); // 고유 ID로 회차 생성

  await foodIntakeDocRef.set({
    'volume': volume,
    'timestamp': FieldValue.serverTimestamp(), // 회차 생성 시간 기록
  });

  print("사료량 기록이 성공적으로 저장되었습니다. Volume: $volume g");
}