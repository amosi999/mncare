import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/auth_screen.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({super.key});

  @override
  _UserInformationScreenState createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  String _nickname = 'hyeonseo';
  final String _initialNickname = 'hyeonseo';
  final String _initialName = 'imhyeonseo';
  final String _initialEmail = 'c2@c.com';
  final String _initialSex = '여성';
  final String _initialBirth = '2009.09.23';
  TextEditingController nicknameController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController sexController = TextEditingController();
  TextEditingController birthController = TextEditingController();

  // 여기서 초기값(유저의 정보) 가져와서 넣어주게 수정
  @override
  void initState() {
    super.initState();
    nicknameController = TextEditingController(text: _nickname);
    nameController.text = _initialName;
    emailController.text = _initialEmail;
    sexController.text = _initialSex;
    birthController.text = _initialBirth;
  }

  @override
  void dispose() {
    nicknameController.dispose();
    nameController.dispose();
    emailController.dispose();
    super.dispose();
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
          '내 정보',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '닉네임',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(nicknameController, '닉네임'),
                      const SizedBox(height: 20),
                      const Text(
                        '이름',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(nameController, '이름', enabled: false),
                      const SizedBox(height: 20),
                      const Text(
                        '이메일',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(emailController, '이메일', enabled: false),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '성별',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: 175,
                                child: _buildTextField(sexController, '성별',
                                    enabled: false),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '생년월일',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: 175,
                                child: _buildTextField(birthController, '생년월일',
                                    enabled: false),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              FirebaseAuth.instance.signOut();
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => const AuthScreen()),
                                (Route<dynamic> route) => false,
                              );
                            },
                            child: const Text(
                              '로그아웃',
                              style: TextStyle(
                                color: Colors.grey,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.grey,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: _buildCompleteButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool enabled = true}) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
      style: const TextStyle(
        fontSize: 17,
      ),
      onChanged: (value) {
        if (label == '닉네임') {
          setState(() {
            _nickname = value;
          });
        }
      },
    );
  }

  Widget _buildCompleteButton() {
    bool isEnabled = _nickname.isNotEmpty && (_nickname != _initialNickname);
    return ElevatedButton(
      onPressed: isEnabled
          ? () {
              // 닉네임 데이터 업데이트 로직으로 수정
              print('nickname: $_nickname');
              Navigator.of(context).pop();
            }
          : null,
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
