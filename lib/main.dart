import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mncare/screens/auth/auth_screen.dart';
import 'package:mncare/screens/main_screen.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pet Care App',
      theme: ThemeData().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 235, 91, 0),
        ),
      ),
      //home: const MainScreen(),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          //FireBase가 토큰을 로딩하지 않았거나 토큰이 아직 있는지 확인하지 않았다면 로딩화면을 보여준다.
          if (snapshot.connectionState == ConnectionState.waiting) {
            //로딩중인 화면
          }
          //로그인 하고 메인 스크린
          if (snapshot.hasData) {
            return const MainScreen();
          }

          //return const InputInfoScreen();
          return const AuthScreen();
        },
      ),
    );
  }
}
