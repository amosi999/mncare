import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

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

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,  // 해상도 설정 480p
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
    if (_image == null) {
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
      
      print('File uploaded: $downloadUrl');
      
      // 여기에 업로드 성공 후 추가 작업을 수행할 수 있습니다.
      // 예: 데이터베이스에 URL 저장, 사용자에게 성공 메시지 표시 등
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지가 성공적으로 업로드되었습니다!')),
      );
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지 업로드 중 오류가 발생했습니다.')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Camera Test")),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30, width: double.infinity),
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