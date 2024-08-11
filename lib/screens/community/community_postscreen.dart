import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;

class CommunityPostScreen extends StatefulWidget {
  final String initialBoard;

  const CommunityPostScreen({Key? key, this.initialBoard = 'normal'}) : super(key: key);

  @override
  _CommunityPostScreenState createState() => _CommunityPostScreenState();
}
class _CommunityPostScreenState extends State<CommunityPostScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedBoard = 'normal'; // 기본값은 일반 게시판

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
    _selectedBoard = widget.initialBoard;
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 내용을 입력해주세요.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('로그인되어 있지 않습니다.');
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final username = userDoc.data()?['username'] ?? '익명';

      String? imageUrl;
      if (_image != null) {
        final fileName = path.basename(_image!.path);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('community/$_selectedBoard/$fileName');

        await storageRef.putFile(_image!);
        imageUrl = await storageRef.getDownloadURL();
      }

      await FirebaseFirestore.instance
          .collection('community')
          .doc(_selectedBoard)
          .collection('posts')
          .add({
        'title': _titleController.text,
        'content': _contentController.text,
        'author': username,
        'authorId': user.uid,
        'createdDate': Timestamp.now(),
        'imageUrl': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시글이 성공적으로 업로드되었습니다!')),
      );

      _titleController.clear();
      _contentController.clear();
      setState(() {
        _image = null;
      });

      Navigator.of(context).pop();
    } catch (e) {
      print('게시글 업로드 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시글 업로드 중 오류가 발생했습니다.')),
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
      appBar: AppBar(
        title: const Text('새 게시글 작성'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedBoard,
              decoration: const InputDecoration(
                labelText: '게시판 선택',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'normal', child: Text('일반 게시판')),
                DropdownMenuItem(value: 'brag', child: Text('자랑 게시판')),
                DropdownMenuItem(value: 'question', child: Text('질문 게시판')),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBoard = newValue!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: '내용',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('이미지 선택'),
                ),
                ElevatedButton(
                  onPressed: _isUploading ? null : _submit,
                  child: _isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('게시글 업로드'),
                ),
              ],
            ),
            if (_image != null) ...[
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 200, // 이미지 뷰어의 너비를 200으로 제한
                  height: 200, // 이미지 뷰어의 높이를 200으로 제한
                  child: Image.file(
                    _image!,
                    fit: BoxFit.cover, // 이미지가 지정된 크기에 맞게 조절되도록 함
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
