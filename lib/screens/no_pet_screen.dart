import 'package:flutter/material.dart';
import 'package:mncare/screens/auth/pet_registration_screen.dart';

class NoPetScreen extends StatelessWidget {
  final String title;

  const NoPetScreen({Key? key, required this.title}) : super(key: key);

  String _getString(String title) {
    switch (title) {
      case 'calendar':
        return '일정을 관리';
      case 'tracking':
        return '건강을 기록';
      case 'pet_doctor':
        return '질환을 검사';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              width: 1,
              color: const Color.fromARGB(255, 200, 200, 200),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '반려동물을 등록하고',
                style: TextStyle(
                  color: Color.fromARGB(255, 120, 120, 120),
                  fontSize: 15,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _getString(title),
                    style: const TextStyle(
                      color: Color.fromARGB(255, 120, 120, 120),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    '해 보세요.',
                    style: TextStyle(
                      color: Color.fromARGB(255, 120, 120, 120),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PetRegistrationScreen(showSkipButton: false),
                    ),
                  );
                },
                child: Container(
                  width: 160,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      width: 2,
                      color: const Color.fromARGB(255, 235, 91, 0),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '반려동물 등록',
                      style: TextStyle(
                        color: Color.fromARGB(255, 235, 91, 0),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}