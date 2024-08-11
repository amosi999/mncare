import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:mncare/screens/tracking/tracking_screen.dart';
import 'package:mncare/screens/tracking/tracking_screen_controller.dart';
import 'package:mncare/screens/community/community_tab.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../widgets/bottom_bar.dart';
import '../widgets/slide_menu.dart';
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

        // Initializing the selected pet
        if (querySnapshot.docs.isNotEmpty) {
          _selectedPet = CommonPet(
              id: querySnapshot.docs.first.id,
              name: querySnapshot.docs.first['petName']);
        }
      });
      // // Setting the initial pet for each controller 고려
      // if (_selectedPet != null) {
      //   _calendarScreenController.setSelectedPet(
      //     Pet(id: _selectedPet!.id, name: _selectedPet!.name),
      //   );
      //   _trackingScreenController.setSelectedPet(
      //     PetTracking.Pet(id: _selectedPet!.id, name: _selectedPet!.name),
      //   );
      // }
// 트래킹 머지 전 펫
//         _pets = querySnapshot.docs
//             .map((doc) => Pet(id: doc.id, name: doc['petName']))
//             .toList();
//         if (_pets.isNotEmpty) {
//           _selectedPet = null;
//           //_calendarScreenController.setSelectedPet(_selectedPet);
//         }
//       });
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
            _calendarScreenController.setSelectedPet(
              Pet(id: _selectedPet!.id, name: _selectedPet!.name),
            );
            _trackingScreenController.setSelectedPet(
              PetTracking.Pet(id: _selectedPet!.id, name: _selectedPet!.name),
            );
          } else {
            _calendarScreenController
                .setSelectedPet(null); // 필요에 따라 null을 넘길 수 있음
            _trackingScreenController.setSelectedPet(null);
          }

          // 필수로 필요한 것들에 대해서만? 나머지는 필요한가? 얘는 나머지 정보고 필요할 수 있음 . 다른곳에서 초기화하던가.

          // 트래킹 머지 전 펫
//         onPetSelected: (pet) {
//           setState(() {
//             _selectedPet = pet;
//           });
//           _calendarScreenController.setSelectedPet(pet);

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
