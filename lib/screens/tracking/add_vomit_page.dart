import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddVomitPage extends StatefulWidget {
  final DateTime date;
  final String petId;
  final Map<String, dynamic>? existingRecord; // 기존 기록을 받을 수 있도록 수정

  const AddVomitPage({
    required this.date,
    required this.petId,
    this.existingRecord,
    super.key,
  });

  @override
  _AddVomitPageState createState() => _AddVomitPageState();
}

class _AddVomitPageState extends State<AddVomitPage> {
  String _selectedType = '';
  String? _recordId;
  final TextEditingController _memoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingRecord != null) {
      _selectedType = widget.existingRecord!['shape'];
      _memoController.text = widget.existingRecord!['memo'] ?? '';
      _recordId = widget.existingRecord!['id'];
    }
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _saveVomitRecord() async {
    if (_selectedType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("구토의 형태 및 색상을 선택해주세요.")),
      );
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String dateStr = widget.date.toIso8601String().split('T').first;

    final vomitDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('pets')
        .doc(widget.petId)
        .collection('tracking')
        .doc(dateStr)
        .collection('vomit')
        .doc(_recordId ??
            FirebaseFirestore.instance
                .collection('dummy')
                .doc()
                .id); // ID가 있으면 수정, 없으면 새로 생성

    await vomitDocRef.set({
      'shape': _selectedType,
      'memo': _memoController.text,
      'timestamp': _recordId == null
          ? FieldValue.serverTimestamp() // 새 기록의 경우 타임스탬프 생성
          : widget.existingRecord!['timestamp'], // 기존 기록 유지
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
          '구토 기록',
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
                    '형태 및 색',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  Wrap(
                    spacing: 5.0,
                    runSpacing: 5.0,
                    alignment: WrapAlignment.start,
                    children: [
                      _buildShapeSelection('무색'),
                      _buildShapeSelection('거품 섞인 무색'),
                      _buildShapeSelection('거품과 음식물'),
                      _buildShapeSelection('노란색'),
                      _buildShapeSelection('잎사귀 섞인 녹색'),
                      _buildShapeSelection('분홍색'),
                      _buildShapeSelection('짙은 갈색'),
                      _buildShapeSelection('녹색'),
                      _buildShapeSelection('이물질 섞인'),
                      _buildShapeSelection('붉은색'),
                    ],
                  ),
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
                      hintText: '예) 9시 밥 먹고 바로 토함',
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
    bool isSelected = _selectedType == shape;

    Image getImage() {
      // _buildShapeSelection('무색'),
      // _buildShapeSelection('거품 섞인 무색'),
      // _buildShapeSelection('거품과 음식물'),
      // _buildShapeSelection('노란색'),
      // _buildShapeSelection('잎사귀 섞인 녹색'),
      // _buildShapeSelection('분홍색'),
      // _buildShapeSelection('짙은 갈색'),
      // _buildShapeSelection('녹색'),
      // _buildShapeSelection('이물질 섞인'),
      // _buildShapeSelection('붉은색'),
      switch (shape) {
        case '무색':
          return Image.asset('assets/images/vomit1.png');
        case '거품 섞인 무색':
          return Image.asset('assets/images/vomit2.png');
        case '거품과 음식물':
          return Image.asset('assets/images/vomit3.png');
        case '노란색':
          return Image.asset('assets/images/vomit4.png');
        case '잎사귀 섞인 녹색':
          return Image.asset('assets/images/vomit5.png');
        case '분홍색':
          return Image.asset('assets/images/vomit6.png');
        case '짙은 갈색':
          return Image.asset('assets/images/vomit7.png');
        case '녹색':
          return Image.asset('assets/images/vomit8.png');
        case '이물질 섞인':
          return Image.asset('assets/images/vomit9.png');
        default:
          return Image.asset('assets/images/vomit10.png');
      }
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = shape;
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
              child: getImage(),
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

  Widget _buildCompleteButton() {
    bool isEnabled = _selectedType.isNotEmpty;
    return ElevatedButton(
      onPressed: isEnabled ? _saveVomitRecord : null,
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
