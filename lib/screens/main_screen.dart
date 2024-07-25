import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../widgets/bottom_bar.dart';
import '../widgets/slide_menu.dart';
import '../widgets/top_app_bar.dart';
import 'calendar/calendar_controller.dart';
import 'calendar/calendar_screen.dart';
import 'community_screen.dart';
import 'home_screen.dart';
import 'pet_doctor_screen.dart';
import 'tracking_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 2;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final CalendarScreenController _calendarScreenController =
      CalendarScreenController(CalendarController());

  @override
  void dispose() {
    _calendarScreenController.dispose();
    super.dispose();
  }

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
        currentCategory: _calendarScreenController.selectedCategory, // 새로 추가
        onCategorySelected: (category) {
          if (_selectedIndex == 1) {
            setState(() {
              _calendarScreenController.setSelectedCategory(category);
            });
          }
        },
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const TrackingScreen(),
          CalendarScreen(controller: _calendarScreenController),
          const HomeScreen(),
          const PetDoctorScreen(),
          const CommunityScreen(),
        ],
      ),
      bottomNavigationBar: BottomBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      endDrawer: const SlideMenu(),
    );
  }
}
