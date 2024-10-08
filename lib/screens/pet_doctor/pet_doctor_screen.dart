import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mncare/screens/pet_doctor/pet_doctor_result.dart';

class Pet {
  final String id;
  final String name;
  Pet({required this.id, required this.name});
}

class PetDoctorScreen extends StatefulWidget {
  final Function? onImageUploaded;

  const PetDoctorScreen({Key? key, this.onImageUploaded}) : super(key: key);

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
            .collection('users')
            .doc(user.uid)
            .collection('pets')
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
        print('반려동물 정보 가져오기 오류: $e');
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

  Future<Map<String, dynamic>> getPrediction(File imageFile) async {
    var request = http.MultipartRequest('POST', Uri.parse('http://192.168.0.9:6245/predict'));
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      return json.decode(responseData);
    } else {
      throw Exception('Failed to get prediction');
    }
  }

  Future<void> _submit() async {
  if (_image == null || _selectedPet == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('이미지나 선택된 펫이 없습니다.')),
    );
    return;
  }

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => PetDoctorResult(
        imageFile: _image!,
        petId: _selectedPet!.id,
        petName: _selectedPet!.name,
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _isCameraView ? _buildFullScreenCameraPreview() : _buildImagePreview(),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          if (_isCameraView)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: _buildCameraControls(),
            ),
          if (!_isCameraView)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: _buildImageControls(),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: const Icon(Icons.photo_library, color: Colors.white, size: 30),
          onPressed: _pickImage,
        ),
        FloatingActionButton(
          onPressed: _takePicture,
          child: const Icon(Icons.camera, size: 36),
        ),
        _buildPetDropdown(),
      ],
    );
  }

  Widget _buildImageControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isCameraView = true;
                  _image = null;
                });
              },
              child: const Text("취소"),
            ),
            ElevatedButton(
              onPressed: _isUploading ? null : _submit,
              child: _isUploading
                  ? const CircularProgressIndicator()
                  : const Text('사진 업로드'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPetDropdown() {
    return DropdownButton<Pet>(
      value: _selectedPet,
      dropdownColor: Colors.black54,
      icon: const Icon(Icons.pets, color: Colors.white),
      items: _pets.map((Pet pet) {
        return DropdownMenuItem<Pet>(
          value: pet,
          child: Text(pet.name, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
      onChanged: (Pet? newValue) {
        setState(() {
          _selectedPet = newValue;
        });
      },
    );
  }

  Widget _buildFullScreenCameraPreview() {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return SizedBox.expand(
            child: Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(_controller!),
                Center(
                  child: CustomPaint(
                    size: Size(MediaQuery.of(context).size.width * 0.8, MediaQuery.of(context).size.width * 0.8),
                    painter: GuidelinePainter(),
                  ),
                ),
              ],
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildImagePreview() {
    return SizedBox.expand(
      child: Image.file(_image!, fit: BoxFit.cover),
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