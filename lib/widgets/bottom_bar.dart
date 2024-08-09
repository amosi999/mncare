import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      selectedItemColor: const Color.fromARGB(250, 235, 91, 0),
      unselectedItemColor: Colors.grey, // 선택되지 않은 아이템의 색상
      selectedFontSize: 12, // 선택된 아이템의 글자 크기
      unselectedFontSize: 12, // 선택되지 않은 아이템의 글자 크기
      backgroundColor: Colors.white, // 배경색
      elevation: 8, // 그림자 효과
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.show_chart),
          label: '트래킹',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: '캘린더',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pets),
          label: '펫닥터',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: '커뮤니티',
        ),
      ],
    );
  }
}
