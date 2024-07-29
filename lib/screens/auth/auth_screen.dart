import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mncare/screens/auth/input_info_screen.dart';

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>(); //전역키
  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _entereduserName = '';

  Future<UserCredential> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return Future.error('Google Sign-In aborted by user.');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredentials =
          await _firebaseAuth.signInWithCredential(credential);
      final user = userCredentials.user;

      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'username': user.displayName ?? 'Unknown',
            'email': user.email ?? 'Unknown',
            'petId': '',
          });

          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (ctx) => const InputInfoScreen(),
              ),
            );
          }
        }
      }

      return userCredentials;
    } catch (error) {
      print('Google Sign-In failed: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google Sign-In failed. Please try again later.'),
          ),
        );
      }
      return Future.error('Google Sign-In failed');
    }
  }

  void _submit() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();

    try {
      if (_isLogin) {
        final userCredentials = await _firebaseAuth.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      } else {
        final userCredentials =
            await _firebaseAuth.createUserWithEmailAndPassword(
                email: _enteredEmail, password: _enteredPassword);
        Navigator.of(context).push(
          MaterialPageRoute(builder: (ctx) => const InputInfoScreen()),
        );
        await FirebaseFirestore.instance //유저 정보 저장
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': _entereduserName,
          'email': _enteredEmail,
          'petId': '',
        });
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication failed.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Email Address'),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid email address.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredEmail = value!;
                            },
                          ),
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Password'),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Password must be at least 6 characters long';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredPassword = value!;
                            },
                          ),
                          if (!_isLogin)
                            TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'Nickname'),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a nickname.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _entereduserName = value!;
                              },
                            ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            child: Text(_isLogin ? 'Login' : 'Signup'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(_isLogin
                                ? 'Create an account'
                                : 'I already have an account.'),
                          ),
                          const SizedBox(height: 12),
                          if (_isLogin)
                            Opacity(
                              opacity: 0.3,
                              child: Container(
                                height: 1.0,
                                width: 500.0,
                                color: const Color.fromARGB(255, 235, 91, 0),
                              ),
                            ),
                          const SizedBox(height: 12),
                          if (_isLogin)
                            ElevatedButton(
                              onPressed: _signInWithGoogle,
                              child: const Text('Sign in with Google'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
