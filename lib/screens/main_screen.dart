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

// 트래킹 머지 전 펫
//   List<Pet> _pets = [];
//   Pet? _selectedPet;

  @override
  void initState() {
    super.initState();
    _calendarScreenController.addListener(_updateState);
    //_trackingScreenController.addListener(_updateState)
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

        if (_pets.isNotEmpty) {
          _selectedPet = _pets.first;
        }
      });
    }
  }

  void _updateState() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
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

    print('index: $index, _selectedPet: $_selectedPet, _pets: $_pets');
    if (index == 0 && _selectedPet == null && _pets.isNotEmpty) {
      setState(() {
        _selectedPet = _pets.first;
      });

      _trackingScreenController.setSelectedPet(
        PetTracking.Pet(id: _selectedPet!.id, name: _selectedPet!.name),
      );
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
          if (_selectedPet != null) {
            print('selected pet: ${_selectedPet!.name}');
            _calendarScreenController.setSelectedPet(
              Pet(id: _selectedPet!.id, name: _selectedPet!.name),
            );
            _trackingScreenController.setSelectedPet(
              PetTracking.Pet(id: _selectedPet!.id, name: _selectedPet!.name),
            );
          } else {
            print('null pet');
            print('null pet selected pet: ${_selectedPet?.name}, ${_pets?.first.name}');
            //pets가 비어있어서 여기서 오류남
            _calendarScreenController
                .setSelectedPet(null); // 필요에 따라 null을 넘길 수 있음
            _trackingScreenController.setSelectedPet(
              PetTracking.Pet(id: _pets.first.id, name: _pets.first.name),
            );
          }
        },
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          TrackingScreen(controller: _trackingScreenController),
          CalendarScreen(controller: _calendarScreenController),
          const HomeScreen(),
          const PetDoctor.PetDoctorList(),
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
