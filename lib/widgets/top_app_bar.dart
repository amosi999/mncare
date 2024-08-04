import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants/app_constants.dart';
import '../screens/calendar/schedule_info.dart';
import '../screens/calendar/schedule_type_dialog.dart';

class TopAppBar extends StatefulWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final VoidCallback onMenuPressed;
  final Function(Pet) onPetSelected;
  final Pet? currentPet; // 현재 선택된 펫
  //  final List<Pet> pets; // 추가된 부분: 펫 목록 // 일단 보류

  const TopAppBar({
    super.key,
    required this.selectedIndex,
    required this.onMenuPressed,
    required this.onPetSelected,
    required this.currentPet,
    // required this.pets, // 추가된 부분: 펫 목록
  });

  @override
  _TopAppBarState createState() => _TopAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _TopAppBarState extends State<TopAppBar> {
  final User? user = FirebaseAuth.instance.currentUser;
  List<Pet> _pets = [];
  Pet? _selectedPet;

  @override
  void initState() {
    super.initState();
    _fetchPets();
  }

  Future<void> _fetchPets() async {
    if (user == null) return;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('pets')
        .get();

    setState(() {
      _pets = querySnapshot.docs
          .map((doc) => Pet(id: doc.id, name: doc.data()['petName'] as String))
          .toList();
      if (_pets.isNotEmpty) {
        _selectedPet = _pets.first;
        widget.onPetSelected(_selectedPet!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: widget.selectedIndex == 1
          ? _buildDropdownMenu()
          : Text(AppConstants.appBarTitles[widget.selectedIndex]),
      backgroundColor: Colors.grey[50],
      actions: [
        if (widget.selectedIndex == 1)
          IconButton(
            icon: const Icon(Icons.loyalty),
            onPressed: () => showScheduleTypeDialog(context),
          ),
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: widget.onMenuPressed,
        ),
      ],
    );
  }

  Widget _buildDropdownMenu() {
    return DropdownButton<Pet>(
      value: _selectedPet,
      onChanged: (Pet? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedPet = newValue;
          });
          widget.onPetSelected(newValue);
        }
      },
      items: _pets.map<DropdownMenuItem<Pet>>((Pet pet) {
        return DropdownMenuItem<Pet>(
          value: pet,
          child: Text(pet.name),
        );
      }).toList(),
    );
  }
}
