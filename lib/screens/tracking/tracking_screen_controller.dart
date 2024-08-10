import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'tracking_info.dart';
import 'calendar_widget.dart';
import 'tracking_grid.dart';

class TrackingScreenController extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();
  Pet? _selectedPet;

  DateTime get selectedDate => _selectedDate;
  Pet? get selectedPet => _selectedPet;

  void updateSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setSelectedPet(Pet? pet) {
    _selectedPet = pet;
    _loadTrackingData(pet);
    notifyListeners();
  }

  void _loadTrackingData(Pet? selectedPet) {
    if (selectedPet == null) return;
    // selectedPet.name를 사용하여 트래킹 데이터를 로드하는 로직을 추가하세요.
    notifyListeners();
  }
}
