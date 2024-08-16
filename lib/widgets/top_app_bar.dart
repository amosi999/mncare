import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../screens/calendar/schedule_info.dart';
import '../screens/calendar/schedule_type_dialog.dart';

class TopAppBar extends StatefulWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final VoidCallback onMenuPressed;
  final bool hasPets;
  final Function(CommonPet?) onPetSelected; // Pet?로 변경하여 null을 전달할 수 있도록 함
  final CommonPet? currentPet; // 현재 선택된 펫
//   final Function(Pet?) onPetSelected; // Pet?로 변경하여 null을 전달할 수 있도록 함
//   final Pet? currentPet; // 현재 선택된 펫
  //  final List<Pet> pets; // 추가된 부분: 펫 목록 // 일단 보류


  const TopAppBar({
    Key? key,
    required this.selectedIndex,
    required this.onMenuPressed,
    required this.onPetSelected,
    required this.currentPet,
    required this.hasPets,
  }) : super(key: key);

  @override
  _TopAppBarState createState() => _TopAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _TopAppBarState extends State<TopAppBar> {
  final User? user = FirebaseAuth.instance.currentUser;
  List<CommonPet> _pets = [];
  CommonPet? _selectedPet;
// 트래킹 머지 전 펫
//   List<Pet> _pets = [];
//   Pet? _selectedPet;

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
          .map((doc) =>
              CommonPet(id: doc.id, name: doc.data()['petName'] as String))
          .toList();
      print('로드 _pets : ${_pets}');

      if (_pets.isNotEmpty) {
        // 트래킹 페이지에서는 "전체" 선택지를 표시하지 않음
        if (widget.selectedIndex != 1) {
          _selectedPet = null;
        } else {
          _selectedPet = _pets.first;
        }
        widget.onPetSelected(_selectedPet);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.hasPets &&
        (widget.selectedIndex == 0 ||
            widget.selectedIndex == 1 ||
            widget.selectedIndex == 3)) {
      // NoPetScreen이 표시되는 경우
      return AppBar(
        backgroundColor: Colors.grey[50],
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(
          AppConstants.appBarTitles[widget.selectedIndex],
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: widget.onMenuPressed,
          ),
        ],
      );
    }

    return AppBar(
      title: (widget.selectedIndex == 0 || widget.selectedIndex == 1)
          ? _buildDropdownMenu(widget.selectedIndex)
          : Text(
              AppConstants.appBarTitles[widget.selectedIndex],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
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

  Widget _buildDropdownMenu(int selectedIndex) {
    if (selectedIndex != 1 && _selectedPet == null && _pets.isNotEmpty) {
      // selectedIndex가 1이 아닐 때 첫 번째 펫을 기본 선택으로 설정
      _selectedPet = _pets.first;
    }
    print('빌드 드롭다운 _selectedPet : ${_selectedPet?.name}');

    return DropdownButton<CommonPet>(
      value: _selectedPet,
      onChanged: (CommonPet? newValue) {
        setState(() {
          _selectedPet = newValue;
        });
        widget.onPetSelected(newValue);
      },
      items: [
        if (widget.selectedIndex == 1)
          const DropdownMenuItem<CommonPet>(
            value: null,
            child: Text('전체'),
          ),
        ..._pets.map<DropdownMenuItem<CommonPet>>((CommonPet pet) {
          return DropdownMenuItem<CommonPet>(
            value: pet,
            child: Text(pet.name),
          );
        }),
      ],
    );
  }
}

class CommonPet {
  final String id;
  final String name;

  CommonPet({required this.id, required this.name});
}
