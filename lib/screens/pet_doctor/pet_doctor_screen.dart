import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;

class Pet {
  final String id;
  final String name;

  Pet({required this.id, required this.name});
}

class PetDoctorScreen extends StatefulWidget {
  const PetDoctorScreen({super.key});

  @override
  State<StatefulWidget> createState() => _PetDoctorScreenState();
}

class _PetDoctorScreenState extends State<PetDoctorScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  File? _image;
  bool _isCameraView = true;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  List<Pet> _pets = [];
  Pet? _selectedPet;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeFirebase();
    _fetchPets();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
  }

  Future<void> _fetchPets() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('pets')
            .where('UserId', isEqualTo: user.uid)
            .get();

        setState(() {
          _pets = querySnapshot.docs.map((doc) => Pet(
            id: doc.id,
            name: doc.data()['petName'] ?? 'Unknown Pet'
          )).toList();

          if (_pets.isNotEmpty) {
            _selectedPet = _pets.first;
          }
        });
      } catch (e) {
        print('Error fetching pets: $e');
      }
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller!.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      setState(() {
        _image = File(image.path);
        _isCameraView = false;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isCameraView = false;
      });
    }
  }

  void _retakePicture() {
    setState(() {
      _image = null;
      _isCameraView = true;
    });
  }

  Future<void> _submit() async {
    if (_image == null || _selectedPet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지나 선택된 펫이 없습니다.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final fileName = path.basename(_image!.path);
      final firebaseStorageRef = FirebaseStorage.instance.ref().child('pet_images/$fileName');
      
      await firebaseStorageRef.putFile(_image!);
      
      final downloadUrl = await firebaseStorageRef.getDownloadURL();
      
      // Firestore에 데이터 저장
      await FirebaseFirestore.instance.collection('pet_images').add({
        'petId': _selectedPet!.id,
        'petName': _selectedPet!.name,  // 펫 이름 추가
        'img_url': downloadUrl,
        'createdDate': FieldValue.serverTimestamp(),
      });
      
      print('File uploaded and data saved: $downloadUrl');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지가 성공적으로 업로드되고 저장되었습니다!')),
      );
    } catch (e) {
      print('Error uploading image and saving data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지 업로드 및 데이터 저장 중 오류가 발생했습니다.')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pet Doctor")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 30, width: double.infinity),
          if (_pets.isNotEmpty)
            DropdownButton<Pet>(
              value: _selectedPet,
              items: _pets.map((Pet pet) {
                return DropdownMenuItem<Pet>(
                  value: pet,
                  child: Text(pet.name),
                );
              }).toList(),
              onChanged: (Pet? newValue) {
                setState(() {
                  _selectedPet = newValue;
                });
              },
            ),
          const SizedBox(height: 20),
          _isCameraView ? _buildCameraPreview() : _buildImagePreview(),
          const SizedBox(height: 20),
          _buildButtons(),
          const SizedBox(height: 20),
          if (_image != null)
            ElevatedButton(
              onPressed: _isUploading ? null : _submit,
              child: _isUploading
                  ? const CircularProgressIndicator()
                  : const Text('사진 업로드'),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return SizedBox(
            width: 400,
            height: 400,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CameraPreview(_controller!),
                CustomPaint(
                  size: const Size(300, 300),
                  painter: GuidelinePainter(),
                ),
              ],
            ),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Widget _buildImagePreview() {
    return SizedBox(
      width: 300,
      height: 300,
      child: Image.file(_image!, fit: BoxFit.cover),
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _isCameraView ? _takePicture : _retakePicture,
          child: Text(_isCameraView ? "사진 찍기" : "다시 찍기"),
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: _pickImage,
          child: const Text("갤러리에서 선택"),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

class GuidelinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.8,
      height: size.width * 0.8,
    );
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}