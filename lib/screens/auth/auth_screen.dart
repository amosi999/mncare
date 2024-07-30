import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();
  String? _gender;
  final _birthController = TextEditingController();

  void _switchAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // 여기에 로그인 또는 회원가입 로직 구현
      print(_isLogin ? '로그인 시도' : '회원가입 시도');
      print('이메일: ${_emailController.text}');
      print('비밀번호: ${_passwordController.text}');
      if (!_isLogin) {
        print('닉네임: ${_nicknameController.text}');
        print('성별: $_gender');
        print('생년월일: ${_birthController.text}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    _isLogin ? '반가워요 👋' : '환영해요 👋',
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.w800),
                    textAlign: TextAlign.start,
                  ),
                  Text(
                    _isLogin ? '로그인 정보를 알려주세요' : '회원가입 정보를 알려주세요',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: '이메일',
                      labelStyle: TextStyle(color: Colors.grey),
                      floatingLabelStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    cursorColor: Colors.black,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '이메일을 입력해주세요';
                      }
                      if (value.trim().isEmpty || !value.contains('@')) {
                        return '올바른 이메일 주소를 입력해주세요';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: '비밀번호',
                      labelStyle: TextStyle(color: Colors.grey),
                      floatingLabelStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '비밀번호를 입력해주세요';
                      }
                      if (!_isLogin && value.length < 6) {
                        return '비밀번호는 6자리 이상이어야 합니다';
                      }
                      return null;
                    },
                  ),
                  if (!_isLogin) ...[
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nicknameController,
                      decoration: const InputDecoration(
                        labelText: '닉네임',
                        labelStyle: TextStyle(color: Colors.grey),
                        floatingLabelStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '닉네임을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: const InputDecoration(
                        labelText: '성별',
                        labelStyle: TextStyle(color: Colors.grey),
                        floatingLabelStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                      items: ['남성', '여성'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _gender = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '성별을 선택해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _birthController,
                      decoration: const InputDecoration(
                        labelText: '생년월일',
                        hintText: 'YYYYMMDD',
                        hintStyle: TextStyle(color: Colors.grey),
                        labelStyle: TextStyle(color: Colors.grey),
                        floatingLabelStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(8),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '생년월일을 입력해주세요';
                        }
                        if (value.length != 8) {
                          return '8자리로 입력해주세요 (YYYYMMDD)';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(200, 50),
                      backgroundColor: const Color.fromARGB(255, 235, 91, 0),
                    ),
                    onPressed: _submit,
                    child: Text(
                      _isLogin ? '로그인' : '회원가입',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (_isLogin) ...[
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(200, 50),
                        backgroundColor: const Color.fromARGB(255, 255, 178, 0),
                      ),
                      onPressed: () {},
                      child: const Text(
                        'Google로 로그인',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 5),
                  TextButton(
                    onPressed: _switchAuthMode,
                    child: Text(
                      _isLogin ? '회원가입' : '로그인',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
