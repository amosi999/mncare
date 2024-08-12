import 'package:flutter/material.dart';
import 'package:mncare/screens/auth/pet_registration_screen.dart';
import 'package:mncare/screens/side_menu/pet_update_screen.dart';
import 'package:mncare/screens/side_menu/setting_screen.dart';
import 'package:mncare/screens/side_menu/user_information_screen.dart';

class SlideMenu extends StatelessWidget {
  const SlideMenu({super.key});

  // 테스트용 데이터
  static const List<String> testData = ['머루', '다래', '뽀돌이', '두부', '베리'];

  Widget _buildPetProfile(BuildContext context, String name) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PetUpdateScreen(petName: name),
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
              name,
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
                // 내 정보 페이지로 이동하는 로직
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
                  // 반려동물 추가 페이지로 이동하는 로직
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
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: testData
                      .map((name) => _buildPetProfile(context, name))
                      .toList(),
                )),
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
                // 설정 페이지로 이동하는 로직
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
