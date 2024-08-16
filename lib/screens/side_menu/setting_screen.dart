import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '설정',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
        children: [
          ListTile(
            trailing: const Icon(Icons.chevron_right_outlined),
            title: const Text(
              '알림 설정',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            onTap: () {},
          ),
          const Divider(
            color: Colors.grey,
            thickness: 0.3,
            height: 10,
          ),
          ListTile(
            trailing: const Icon(Icons.chevron_right_outlined),
            title: const Text(
              '이용 약관',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            onTap: () {},
          ),
          const Divider(
            color: Colors.grey,
            thickness: 0.3,
            height: 10,
          ),
          ListTile(
            trailing: const Icon(Icons.chevron_right_outlined),
            title: const Text(
              '개인정보 처리 방침',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
