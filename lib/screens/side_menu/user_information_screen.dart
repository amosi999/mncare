import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/auth_screen.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({super.key});

  @override
  _UserInformationScreenState createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nicknameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController sexController = TextEditingController();
  TextEditingController birthController = TextEditingController();

  bool _isLoading = true;
  String _initialNickname = '';
  bool _isNicknameChanged = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    nicknameController.addListener(_onNicknameChanged);
  }

  @override
  void dispose() {
    nicknameController.removeListener(_onNicknameChanged);
    nicknameController.dispose();
    emailController.dispose();
    sexController.dispose();
    birthController.dispose();
    super.dispose();
  }

  void _onNicknameChanged() {
    setState(() {
      _isNicknameChanged = nicknameController.text != _initialNickname;
    });
  }

  Future<void> _showDeleteConfirmDialog() async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("회원 탈퇴"),
          content: const Text("정말로 탈퇴하시겠습니까? 이 작업은 되돌릴 수 없습니다."),
          actions: <Widget>[
            TextButton(
              child: const Text("취소"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text("탈퇴"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      _showPasswordInputDialog();
    }
  }

  Future<void> _showPasswordInputDialog() async {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("비밀번호 확인"),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '비밀번호를 입력해주세요';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("취소"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text("확인"),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(true);
                }
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      _deleteAccount(passwordController.text);
    }
  }

  Future<void> _deleteAccount(String password) async {
  try {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && currentUser.email != null) {
      // 사용자 재인증
      AuthCredential credential = EmailAuthProvider.credential(
        email: currentUser.email!,
        password: password,
      );
      await currentUser.reauthenticateWithCredential(credential);

      // Firestore에서 사용자 관련 모든 데이터 삭제
      await _deleteUserData(currentUser.uid);

      // Firebase Authentication에서 사용자 삭제
      await currentUser.delete();

      // 로그인 화면으로 이동
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (Route<dynamic> route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원 탈퇴가 완료되었습니다.')),
      );
    } else {
      throw Exception('로그인된 사용자가 없습니다');
    }
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('회원 탈퇴에 실패했습니다: $error')),
    );
  }
}

Future<void> _deleteUserData(String userId) async {
  // 사용자 문서 참조
  DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);

  // 사용자의 하위 컬렉션들 (예: pets, schedules 등)
  List<String> subCollections = ['pets', 'schedules', 'categories'];

  // 각 하위 컬렉션의 문서들을 삭제
  for (String collection in subCollections) {
    QuerySnapshot snapshots = await userRef.collection(collection).get();
    for (DocumentSnapshot doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }

  // 마지막으로 사용자 문서 자체를 삭제
  await userRef.delete();
}

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            nicknameController.text = data['username'] ?? '';
            _initialNickname = data['username'] ?? '';
            emailController.text = data['email'] ?? '';
            sexController.text = data['gender'] ?? '';
            birthController.text = data['birthdate'] ?? '';
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자 정보를 불러오는 데 실패했습니다.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '내 정보 수정',
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
                  child: Form(
                    key: _formKey,
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
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
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
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: 175,
                                  child: _buildTextField(
                                      birthController, '생년월일',
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
                                  decorationColor: Colors.grey,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: Container(
                                width: 0.5,
                                height: 15,
                                color: Colors.grey,
                              ),
                            ),
                             GestureDetector(
      onTap: _showDeleteConfirmDialog,
      child: const Text(
        '회원탈퇴',
        style: TextStyle(
          color: Colors.grey,
          decorationColor: Colors.grey,
        ),
      ),
    ),
                          ],
                        ),
                      ],
                    ),
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
          _onNicknameChanged();
        }
      },
    );
  }

  Widget _buildCompleteButton() {
    return ElevatedButton(
      onPressed: _isNicknameChanged ? _updateUserInfo : null,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: _isNicknameChanged
            ? const Color.fromARGB(255, 235, 91, 0)
            : Colors.grey,
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

  void _updateUserInfo() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .update({
            'username': nicknameController.text,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('사용자 정보가 성공적으로 업데이트되었습니다!')),
          );

          Navigator.of(context).pop();
        } else {
          throw Exception('로그인된 사용자가 없습니다');
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사용자 정보 업데이트에 실패했습니다: $error')),
        );
      }
    }
  }
}
