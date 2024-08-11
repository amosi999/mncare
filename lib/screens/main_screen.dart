import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:mncare/screens/tracking/tracking_screen.dart';
import 'package:mncare/screens/tracking/tracking_screen_controller.dart';
import 'package:mncare/screens/community/community_tab.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../widgets/bottom_bar.dart';
import '../widgets/side_menu.dart';
import '../widgets/top_app_bar.dart';
import 'calendar/calendar_controller.dart';
import 'calendar/calendar_screen.dart';
import 'home_screen.dart';
import 'package:mncare/screens/pet_doctor/pet_doctor_list.dart' as PetDoctor;
import 'calendar/schedule_info.dart';
import 'tracking/tracking_info.dart' as PetTracking;
import 'no_pet_screen.dart';

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
  final TrackingScreenController _trackingScreenController =
      TrackingScreenController();
  List<CommonPet> _pets = [];
  CommonPet? _selectedPet;
  bool _hasPets = false;

  @override
  void initState() {
    super.initState();
    _calendarScreenController.addListener(_updateState);
    _fetchPets();
  }

  Future<void> _fetchPets() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('pets')
          .get();

      setState(() {
        _pets = querySnapshot.docs
            .map((doc) => CommonPet(id: doc.id, name: doc['petName']))
            .toList();
        _hasPets = _pets.isNotEmpty;
        if (_hasPets) {
          _selectedPet = _pets.first;
          _updateSelectedPet(_selectedPet);
        }
      });
    }
  }

  void _updateSelectedPet(CommonPet? pet) {
    if (pet != null) {
      _calendarScreenController.setSelectedPet(
        Pet(id: pet.id, name: pet.name),
      );
      _trackingScreenController.setSelectedPet(
        PetTracking.Pet(id: pet.id, name: pet.name),
      );
    } else {
      _calendarScreenController.setSelectedPet(null);
      _trackingScreenController.setSelectedPet(null);
    }
  }

  void _updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _calendarScreenController.removeListener(_updateState);
    _calendarScreenController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      _calendarScreenController.resetToToday();
    }
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
        currentPet: _selectedPet,
        onPetSelected: (CommonPet? pet) {
          setState(() {
            _selectedPet = pet;
          });
          _updateSelectedPet(pet);
        },
        hasPets: _hasPets,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _hasPets
              ? TrackingScreen(controller: _trackingScreenController)
              : const NoPetScreen(title: 'tracking'),
          _hasPets
              ? CalendarScreen(controller: _calendarScreenController)
              : const NoPetScreen(title: 'calendar'),
          const HomeScreen(),
          _hasPets
              ? const PetDoctor.PetDoctorList()
              : const NoPetScreen(title: 'pet_doctor'),
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