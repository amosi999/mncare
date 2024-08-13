import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddWaterPage extends StatefulWidget {
  final DateTime date;
  final String petId;

  const AddWaterPage({required this.date, required this.petId, Key? key})
      : super(key: key);

  @override
  _AddWaterPageState createState() => _AddWaterPageState();
}

class _AddWaterPageState extends State<AddWaterPage> {
  double _inputVolume = 0;
  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _updateVolume(String value) {
    setState(() {
      _inputVolume = double.tryParse(value) ?? 0;
    });
  }

  Future<void> _saveWaterIntake() async {
    if (_inputVolume <= 0) {
      // 잘못된 값 입력 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("올바른 음수량을 입력하세요.")),
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
        .collection('water')
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
          '음수량 기록',
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
                  '음수량',
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
                      hintText: '0',
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
                  'ml',
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
      onPressed: hasInput ? _saveWaterIntake : null,
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