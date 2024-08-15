import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'tracking_info.dart';

class TrackingScreenController extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();
  Pet? _selectedPet;

  DateTime get selectedDate => _selectedDate;
  Pet? get selectedPet => _selectedPet;

  void updateSelectedDate(DateTime date) {
    _selectedDate = date;
    _initializeTrackingDataIfNeeded();
    notifyListeners();
  }

  void setSelectedPet(Pet? pet) {
    _selectedPet = pet;
    _initializeTrackingDataIfNeeded();
    notifyListeners();
  }

  Future<void> _initializeTrackingDataIfNeeded() async {
    print('펫 정보 초기화 ${_selectedPet?.name}' ); 
   //if (_selectedPet == null) return;

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final trackingDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('pets')
        .doc(_selectedPet!.id)
        .collection('tracking')
        .doc(_selectedDate.toIso8601String().split('T').first);

    final docSnapshot = await trackingDocRef.get();

    if (!docSnapshot.exists) {
      // 여기서 기본 값을 설정하여 초기화합니다.
      await trackingDocRef.set({
        'foodGoal': await _getDefaultFromStandard('defaultFoodGoal'),
        'foodCount': await _getDefaultFromStandard('defaultFoodCount'),
        'foodKcal': await _getDefaultFromStandard('defaultFoodKcal'),
        'waterGoal': await _getDefaultFromStandard('defaultWaterGoal'),
        'waterCount': await _getDefaultFromStandard('defaultWaterCount'),
      });
    }
  }

  Future<dynamic> _getDefaultFromStandard(String field) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final standardDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('pets')
        .doc(_selectedPet!.id)
        .collection('standard')
        .doc('document');

    final standardDoc = await standardDocRef.get();

    return standardDoc.exists ? standardDoc[field] : null;
  }

  
}
