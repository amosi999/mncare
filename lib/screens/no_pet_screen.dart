import 'package:flutter/material.dart';

class NoPetScreen extends StatelessWidget {
  final String title;

  const NoPetScreen({super.key, required this.title});

  String _getString(String titile) {
    if (title == 'calendar') {
      return '일정을 관리';
    } else if (title == 'pet_doctor') {
      return '질환을 검사';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 240, 240),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 275, 20, 275),
          child: Container(
            height: double.infinity,
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
                  onTap: () {}, // 반려동물 등록 화면으로 넘어가게 수정 (근데이제 건너뛰기는 뜨면안됨)
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
      ),
    );
  }
}
