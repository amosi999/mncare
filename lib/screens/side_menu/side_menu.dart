import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mncare/screens/auth/pet_registration_screen.dart';
import 'package:mncare/screens/side_menu/pet_update_screen.dart';
import 'package:mncare/screens/side_menu/setting_screen.dart';
import 'package:mncare/screens/side_menu/user_information_screen.dart';

class SlideMenu extends StatefulWidget {
  const SlideMenu({super.key});

  @override
  _SlideMenuState createState() => _SlideMenuState();
}

class _SlideMenuState extends State<SlideMenu> {
  List<Map<String, dynamic>> _petList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPetList();
  }

  Future<void> _loadPetList() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        QuerySnapshot petSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('pets')
            .get();

        setState(() {
          _petList = petSnapshot.docs
              .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
              .toList();
        });
      }
    } catch (e) {
      print('Error loading pet list: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildPetProfile(BuildContext context, Map<String, dynamic> pet) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PetUpdateScreen(petId: pet['id']),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
        child: Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 255, 178, 0),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              pet['petName'] ?? '',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: SizedBox(
              height: 85,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '마이페이지',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: ListTile(
              trailing: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chevron_right_sharp),
                  SizedBox(width: 10),
                ],
              ),
              title: const Text(
                '내 정보',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserInformationScreen(),
                  ),
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Divider(
              color: Colors.grey,
              thickness: 0.3,
              height: 10,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: ListTile(
              trailing: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const PetRegistrationScreen(showSkipButton: false),
                    ),
                  );
                },
              ),
              title: const Text(
                '반려동물',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 100,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _petList
                          .map((pet) => _buildPetProfile(context, pet))
                          .toList(),
                    ),
                  ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Divider(
              color: Colors.grey,
              thickness: 0.3,
              height: 10,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: ListTile(
              trailing: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chevron_right_sharp),
                  SizedBox(width: 10),
                ],
              ),
              title: const Text(
                '설정',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}