import 'package:flutter/material.dart';
import 'package:mncare/screens/tracking/tracking_screen_controller.dart';
import 'package:mncare/utilities/utils.dart';

import 'add_ poop_page.dart';
import 'add_vomit_page.dart';
import 'detail_page.dart';

class TrackingGrid extends StatelessWidget {
  final TrackingScreenController controller; // 추가: 컨트롤러 필드

  const TrackingGrid({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        child: ListView(
          children: [
            // volume에 (현재기록량 / 목표량) 해서 소수점 한자릿수로 넣어주기 (0.0 ~ 1.0 범위)
            const SizedBox(height: 15),
            _buildTrackingItem(context, '물', volume: 0.4),
            const SizedBox(height: 15),
            _buildTrackingItem(context, '사료', volume: 0.6),
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

  Widget _buildTrackingItem(BuildContext context, String title,
      {double? volume}) {
    double getVolume() {
      if (volume != null) {
        return volume;
      }
      return 0;
    }

    BoxDecoration getDecoration(String title) {
      switch (title) {
        case '물':
          return BoxDecoration(
            gradient: LinearGradient(
              colors: const [Color.fromARGB(255, 81, 156, 231), Colors.white],
              stops: [getVolume(), getVolume()],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(25),
          );
        case '사료':
          return BoxDecoration(
            gradient: LinearGradient(
              colors: const [Color.fromARGB(255, 117, 88, 66), Colors.white],
              stops: [getVolume(), getVolume()],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(25),
          );
        default:
          return BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          );
      }
    }

    return GestureDetector(
      onTap: () async {
        if (title == '물') {
          //회차 물 1회 추가
          await saveWaterIntake(
            date: controller.selectedDate,
            petId: controller.selectedPet!.id,
          );
          // 물 1회차 추가되었다는 알림을 표시
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('물 1회차가 추가되었습니다.'),
              duration: Duration(seconds: 1), // 알림이 2초 동안 표시됩니다.
            ),
          );
          print('물 추가');
        } else if (title == '사료') {
          //회차 사료 1회 추가
          await saveFoodIntake(
            date: controller.selectedDate,
            petId: controller.selectedPet!.id,
          );
          // 사료 1회차 추가되었다는 알림을 표시
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('사료 1회차가 추가되었습니다.'),
              duration: Duration(seconds: 1), // 알림이 2초 동안 표시됩니다.
            ),
          );
          print('사료 추가');
        } else if (title == '대변') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddPoopPage(
                      date: controller.selectedDate,
                      petId: controller.selectedPet!.id,
                    )),
          );
        } else if (title == '구토') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddVomitPage(
                      date: controller.selectedDate,
                      petId: controller.selectedPet!.id,
                    )),
          );
        }
      },
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: getDecoration(title),
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
                          builder: (context) => DetailPage(
                            title: title,
                            controller: controller,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.chevron_right,
                    ),
                  ),
                ],
              ),
              if (title == '물' || title == '사료')
                const Icon(
                  Icons.add,
                  color: Color.fromARGB(50, 0, 0, 0),
                  size: 50,
                )
            ],
          ),
        ),
      ),
    );
  }
}
