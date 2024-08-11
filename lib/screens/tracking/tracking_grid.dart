import 'package:flutter/material.dart';

import 'add_ poop_page.dart';
import 'add_vomit_page.dart';
import 'detail_page.dart';

class TrackingGrid extends StatelessWidget {
  const TrackingGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        child: ListView(
          children: [
            const SizedBox(height: 15),
            _buildTrackingItem(context, '물'),
            const SizedBox(height: 15),
            _buildTrackingItem(context, '사료'),
            const SizedBox(height: 15),
            _buildTrackingItem(context, '대변'),
            const SizedBox(height: 15),
            _buildTrackingItem(context, '구토'),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingItem(BuildContext context, String title) {
    return GestureDetector(
      onTap: () {
        if (title == '물') {
          // 물 추가 로직
          print('물 추가');
        } else if (title == '사료') {
          // 사료 추가 로직
          print('사료 추가');
        } else if (title == '대변') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPoopPage()),
          );
        } else if (title == '구토') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddVomitPage()),
          );
        }
      },
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 10, 10, 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(title: title),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.chevron_right,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
