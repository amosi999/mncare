import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddFoodPage extends StatefulWidget {
  final DateTime date;
  final String petId;
  final int foodCount;
  final int foodGoal;

  const AddFoodPage({
    required this.date,
    required this.petId,
    required this.foodCount,
    required this.foodGoal,
    Key? key,
  }) : super(key: key);

  @override
  _AddFoodPageState createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  int _inputVolume = 0;
  late TextEditingController _inputController;

  @override
  void initState() {
    super.initState();
    _inputVolume = (widget.foodGoal / widget.foodCount as num).toInt();
    _inputController = TextEditingController(
      text: '$_inputVolume', // 기본값 설정
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _updateVolume(String value) {
    setState(() {
      _inputVolume = int.tryParse(value) ?? 0;
    });
  }

  Future<void> _saveFoodIntake() async {
    if (_inputVolume <= 0) {
      // 잘못된 값 입력 처리
      print(
          'inputVolume: $_inputVolume, _inputVolume.type  : ${_inputVolume.runtimeType}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("올바른 사료량을 입력하세요.")),
      );
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String dateStr = widget.date.toIso8601String().split('T').first;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('pets')
        .doc(widget.petId)
        .collection('tracking')
        .doc(dateStr)
        .collection('food')
        .doc(); // 고유 ID로 회차 생성

    await docRef.set({
      'volume': _inputVolume,
      'timestamp': FieldValue.serverTimestamp(), // 회차 생성 시간 기록
    });

    Navigator.of(context).pop(true); // 기록 추가 후 이전 화면으로 돌아가기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '사료량 기록',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  '사료량',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 200),
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    maxLines: 1,
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.number,
                    cursorColor: Colors.black,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                    onChanged: _updateVolume,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'g',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            _buildCompleteButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleteButton() {
    bool hasInput = _inputController.text.isNotEmpty;
    return ElevatedButton(
      onPressed: hasInput ? _saveFoodIntake : null,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: hasInput
            ? const Color.fromARGB(255, 235, 91, 0)
            : Colors.grey, // 비활성화 시 회색으로 변경
        disabledBackgroundColor: const Color.fromARGB(255, 222, 222, 222),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        minimumSize: const Size(double.infinity, 55),
      ),
      child: const Text(
        '완료',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
