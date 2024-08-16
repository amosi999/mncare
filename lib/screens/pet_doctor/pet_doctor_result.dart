import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;

class PetDoctorResult extends StatefulWidget {
  final File imageFile;
  final String petId;
  final String petName;

  const PetDoctorResult({
    Key? key,
    required this.imageFile,
    required this.petId,
    required this.petName,
  }) : super(key: key);

  @override
  _PetDoctorResultState createState() => _PetDoctorResultState();
}

class _PetDoctorResultState extends State<PetDoctorResult> {
  bool _isLoading = true;
  Map<String, dynamic>? _predictionResult;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _predictAndUpload();
  }

  Future<void> _predictAndUpload() async {
    try {
      final predictionResult = await _getPrediction(widget.imageFile);
      final imageUrl = await _uploadImage(widget.imageFile);
      await _saveToFirestore(imageUrl, predictionResult);

      setState(() {
        _predictionResult = predictionResult;
        _imageUrl = imageUrl;
        _isLoading = false;
      });
    } catch (e) {
      print('Error during prediction and upload: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _getPrediction(File imageFile) async {
    var request = http.MultipartRequest('POST', Uri.parse('http://192.168.0.9:6245/predict'));
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      return json.decode(responseData)['result'];
    } else {
      throw Exception('Failed to get prediction');
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    final fileName = path.basename(imageFile.path);
    final storageRef = FirebaseStorage.instance.ref()
        .child('petDoctor/${user.uid}/${widget.petName}/$fileName');
    
    await storageRef.putFile(imageFile);
    return await storageRef.getDownloadURL();
  }

  Future<void> _saveToFirestore(String imageUrl, Map<String, dynamic> predictionResult) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('pets')
        .doc(widget.petId)
        .collection('petDoctor')
        .add({
      'img_url': imageUrl,
      'createdDate': FieldValue.serverTimestamp(),
      'prediction': predictionResult,
    });
  }

  String _getSymptomName(int classNumber) {
    switch (classNumber) {
      case 1: return '구진 플라크';
      case 2: return '비듬 각질 상피성잔고리';
      case 3: return '태선화 과다 색소 침착';
      case 4: return '농포 여드름';
      case 5: return '미란 궤양';
      case 6: return '결절 종괴';
      case 7: return '무증상';
      default: return '알 수 없음';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('진단 결과'),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(
                    '진단 중입니다...',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    if (_imageUrl != null)
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            _imageUrl!,
                            width: 300,
                            height: 300,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    const SizedBox(height: 30),
                    if (_predictionResult != null) ...[
                      Text(
                        '진단 결과',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 15),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text(
                                '증상',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _getSymptomName(_predictionResult!['predicted_class']),
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                '신뢰도',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${(_predictionResult!['confidence'] * 100).toStringAsFixed(2)}%',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 30),
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // 결과 화면 닫기
                        Navigator.of(context).pop(); // PetDoctorScreen 닫기
                      },
                      child: const Text('완료', style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}