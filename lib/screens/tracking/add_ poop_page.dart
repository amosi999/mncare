import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddPoopPage extends StatefulWidget {
  final DateTime date;
  final String petId;

  const AddPoopPage({
    required this.date,
    required this.petId,
    Key? key,
  }) : super(key: key);

  @override
  _AddPoopPageState createState() => _AddPoopPageState();
}

class _AddPoopPageState extends State<AddPoopPage> {
  String _selectedShape = '';
  String _selectedColor = '';
  final TextEditingController _memoController = TextEditingController();

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _savePoopRecord() async {
    if (_selectedShape.isEmpty || _selectedColor.isEmpty) {
      // 선택되지 않은 항목이 있을 경우 처리
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("형태와 색을 모두 선택해주세요.")),
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
        .collection('poop')
        .doc(); // 고유 ID로 회차 생성

    await docRef.set({
      'shape': _selectedShape,
      'color': _selectedColor,
      'memo': _memoController.text,
      'timestamp': FieldValue.serverTimestamp(), // 기록 시간 저장
    });
print('저장성공');
print(docRef);

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
          '대변 기록',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '형태',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  Wrap(
                    spacing: 5.0,
                    runSpacing: 5.0,
                    alignment: WrapAlignment.start,
                    children: [
                      _buildShapeSelection('적당한 단단함'),
                      _buildShapeSelection('촉촉한 작은 통나무'),
                      _buildShapeSelection('딱딱한 토끼'),
                      _buildShapeSelection('질척거리는 통나무'),
                      _buildShapeSelection('촉촉한 무더기'),
                      _buildShapeSelection('질감 있는 흙'),
                      _buildShapeSelection('질감 없는 물'),
                      _buildShapeSelection('대변 안 봄'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '색',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  _buildColorSelection(),
                  const SizedBox(height: 20),
                  const Text(
                    '메모',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _memoController,
                    maxLines: 5,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      hintText: '예) 비린내가 남',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: _buildCompleteButton(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShapeSelection(String shape) {
    bool isSelected = _selectedShape == shape;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedShape = shape;
        });
      },
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.grey[200],
              border: Border.all(
                color: isSelected
                    ? Colors.black
                    : const Color.fromARGB(0, 0, 0, 0),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                '그림으로 대체',
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
          Text(
            shape,
            style: TextStyle(
              fontSize: 15,
              color: isSelected ? Colors.black : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSelection() {
    final colors = [
      'brown',
      'black',
      'red',
      'orange',
      'grey',
      'yellow',
      'green',
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: colors.map((color) => _colorItem(color)).toList(),
    );
  }

  Widget _colorItem(String color) {
    bool isSelected = _selectedColor == color;
    Color c = Colors.white;
    switch (color) {
      case 'brown':
        c = Colors.brown;
        break;
      case 'black':
        c = Colors.black;
        break;
      case 'red':
        c = Colors.red;
        break;
      case 'orange':
        c = Colors.orange;
        break;
      case 'grey':
        c = Colors.grey;
        break;
      case 'yellow':
        c = Colors.yellow;
        break;
      case 'green':
        c = Colors.green;
        break;
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.black, width: 1) : null,
        ),
        child: Center(
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompleteButton() {
    bool isEnabled = _selectedShape.isNotEmpty && _selectedColor.isNotEmpty;
    return ElevatedButton(
      onPressed: isEnabled ? _savePoopRecord : null,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: isEnabled
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
