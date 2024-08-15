import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddWaterPage extends StatefulWidget {
  final DateTime date;
  final String petId;
  final int waterCount;
  final int waterGoal;
  final Map<String, dynamic>? existingRecord;

  const AddWaterPage({
    required this.date,
    required this.petId,
    required this.waterCount,
    required this.waterGoal,
    this.existingRecord,
    Key? key,
  }) : super(key: key);

  @override
  _AddWaterPageState createState() => _AddWaterPageState();
}

class _AddWaterPageState extends State<AddWaterPage> {
  int _inputVolume = 0;
  String? _recordId;
  late TextEditingController _inputController;

  @override
  void initState() {
    super.initState();
    if (widget.existingRecord != null) {
      _inputVolume = widget.existingRecord!['volume'];
      _recordId = widget.existingRecord!['id']; // Track the ID
    } else {
      _inputVolume = (widget.waterGoal / widget.waterCount as num).toInt();
    }
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

  Future<void> _saveWaterIntake() async {
    if (_inputVolume <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("올바른 음수량을 입력하세요.")),
      );
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String dateStr = widget.date.toIso8601String().split('T').first;

    final trackingDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('pets')
        .doc(widget.petId)
        .collection('tracking')
        .doc(dateStr);

    final waterCollectionRef = trackingDocRef.collection('water');

    final docRef = waterCollectionRef.doc(
        _recordId ?? FirebaseFirestore.instance.collection('dummy').doc().id);

    await docRef.set({
      'volume': _inputVolume,
      'timestamp': _recordId == null
          ? FieldValue.serverTimestamp()
          : widget.existingRecord!['timestamp'],
    });

    // currentWater 업데이트 로직
    final allDocsSnapshot = await waterCollectionRef.get();
    int currentWater = allDocsSnapshot.docs.fold(0, (sum, doc) {
      return sum + (doc['volume'] as int);
    });

    // currentWater를 Firestore의 tracking 문서에 저장
    await trackingDocRef.update({'currentWater': currentWater});

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
                    cursorColor: const Color.fromRGBO(0, 0, 0, 1),
                    decoration: const InputDecoration(
                      //hintText: '$_inputController.text',
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
