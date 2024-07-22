import 'package:flutter/material.dart';

import 'screens/calendar_screen.dart';
import 'screens/community_screen.dart';
import 'screens/home_screen.dart';
import 'screens/pet_doctor_screen.dart';
import 'screens/tracking_screen.dart';
import 'widgets/bottom_bar.dart';
import 'widgets/slide_menu.dart';
import 'widgets/top_app_bar.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Care App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 2; // 홈 화면을 기본으로 설정
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    const TrackingScreen(),
    const CalendarScreen(),
    const HomeScreen(),
    const PetDoctorScreen(),
    const CommunityScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openEndDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: TopAppBar(
        selectedIndex: _selectedIndex,
        onMenuPressed: _openEndDrawer,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      endDrawer: SlideMenu(),
    );
  }
}
