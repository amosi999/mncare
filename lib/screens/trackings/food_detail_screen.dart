import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class FoodDetailScreen extends StatefulWidget {
  final String label;
  final int dailyGoal;
  final int feedingTimes;
  final Function(int, int) onSave;
  final String selectedPetId;

  FoodDetailScreen({
    required this.label,
    required this.dailyGoal,
    required this.feedingTimes,
    required this.onSave,
    required this.selectedPetId,
  });

  @override
  _FoodDetailScreenState createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  late int _dailyGoal;
  late int _feedingTimes;
  late int _count;
  late int _currentFood;
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _dailyGoal = widget.dailyGoal;
    _feedingTimes = widget.feedingTimes;
    _count = 0; // Initialize _count to avoid LateInitializationError
    _currentFood = 0; // Initialize _currentFood to avoid LateInitializationError
    _loadTrackingData();
  }

  Future<void> _loadTrackingData() async {
    if (user == null) return;

    final String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final DocumentSnapshot doc = await _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('pets')
        .doc(widget.selectedPetId) // _selectedPetId from TrackingScreen
        .collection('trackings')
        .doc(formattedDate)
        .get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        setState(() {
          _dailyGoal = data['daily_goal_food'] ?? _dailyGoal;
          _feedingTimes = data['feeding_times_food'] ?? _feedingTimes;
          _count = data['food'] ?? 0;
          _currentFood = (_count * (_dailyGoal / _feedingTimes)).toInt();
        });
      }
    } else {
      // 권장 사료량 공식을 적용하여 초기화
      setState(() {
        _dailyGoal = _calculateRecommendedFoodGoal();
        _feedingTimes = 4;
        _count = 0;
        _currentFood = 0;
      });
    }
  }

  int _calculateRecommendedFoodGoal() {
    // 여기에 권장 사료량 공식
    return 100; // 예시로 100을 반환
  }

  void _saveChanges() {
    widget.onSave(_dailyGoal, _feedingTimes);
    Navigator.of(context).pop();
  }

  Future<void> _updateTrackingData() async {
    if (user == null) return;

    final String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final DocumentReference docRef = _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('pets')
        .doc(widget.selectedPetId) // _selectedPetId from TrackingScreen
        .collection('trackings')
        .doc(formattedDate);

    await docRef.set({
      'daily_goal_food': _dailyGoal,
      'feeding_times_food': _feedingTimes,
      'food': _count,
    }, SetOptions(merge: true));
  }

  void _incrementCount() {
    setState(() {
      _count++;
      _currentFood = (_count * (_dailyGoal / _feedingTimes)).toInt();
    });
    _updateTrackingData();
  }

  void _editDailyGoalAndFeedingTimes() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('사료 목표 수정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: '일일 목표 사료의 양 (g)',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _dailyGoal = int.tryParse(value) ?? _dailyGoal;
                    _currentFood = (_count * (_dailyGoal / _feedingTimes)).toInt();
                  });
                },
                controller: TextEditingController(text: _dailyGoal.toString()),
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: '사료 주는 횟수',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _feedingTimes = int.tryParse(value) ?? _feedingTimes;
                    _currentFood = (_count * (_dailyGoal / _feedingTimes)).toInt();
                  });
                },
                controller: TextEditingController(text: _feedingTimes.toString()),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('저장'),
              onPressed: () {
                _saveChanges();
                _updateTrackingData();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isToday = DateFormat('yyyy-MM-dd').format(DateTime.now()) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.label} 상세보기'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                'assets/images/food_screen_main.png', // 경로에 위치한 이미지 파일명
                width: 200,
                height: 200,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$_currentFood / $_dailyGoal g',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              '$_count / $_feedingTimes 회',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _editDailyGoalAndFeedingTimes,
              child: Text('사료 목표 수정'),
            ),
            const SizedBox(height: 16),
            Text(
              '권장 사료량: ${_calculateRecommendedFoodGoal()}g',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
