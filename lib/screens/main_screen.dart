import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mncare/screens/community/community_tab.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../widgets/bottom_bar.dart';
import '../widgets/slide_menu.dart';
import '../widgets/top_app_bar.dart';
import 'calendar/calendar_controller.dart';
import 'calendar/calendar_screen.dart';
import 'home_screen.dart';
import 'package:mncare/screens/pet_doctor/pet_doctor_list.dart' as PetDoctor;
import 'tracking_screen.dart';
import 'calendar/schedule_info.dart';
import 'no_pet_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 2;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final CalendarScreenController _calendarScreenController =
      CalendarScreenController(CalendarController());
  List<Pet> _pets = [];
  Pet? _selectedPet;
  bool _hasPets = false;

  @override
  void initState() {
    super.initState();
    _calendarScreenController.addListener(_updateState);
    _fetchPets();
    _checkForPets();
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
            .map((doc) => Pet(id: doc.id, name: doc['petName']))
            .toList();
        if (_pets.isNotEmpty) {
          _selectedPet = _pets.first;
          _calendarScreenController.setSelectedPet(_selectedPet);
        }
      });
    }
  }

  Future<void> _checkForPets() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot petsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('pets')
          .limit(1)
          .get();

      setState(() {
        _hasPets = petsSnapshot.docs.isNotEmpty;
      });
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
        onPetSelected: (pet) {
          setState(() {
            _selectedPet = pet;
          });
          _calendarScreenController.setSelectedPet(pet);
        },
        currentPet: _selectedPet,
        hasPets: _hasPets,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _hasPets ? const TrackingScreen() : const NoPetScreen(title: 'tracking'),
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
