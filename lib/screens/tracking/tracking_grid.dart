import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mncare/screens/tracking/tracking_screen_controller.dart';
import 'package:mncare/utilities/utils.dart';

import 'add_ poop_page.dart';
import 'add_vomit_page.dart';
import 'detail_page.dart';

class TrackingGrid extends StatefulWidget {
  final TrackingScreenController controller;

  TrackingGrid({super.key, required this.controller});

  @override
  _TrackingGridState createState() => _TrackingGridState();
}

class _TrackingGridState extends State<TrackingGrid> {
  int waterGoal = 0;
  int foodGoal = 0;
  int currentWater = 0;
  int currentFood = 0;

  @override
  void initState() {
    super.initState();
    _loadTrackingData(); // 초기화 시 트래킹 데이터를 로드합니다.
  }

  Future<void> _loadTrackingData() async {
    try {
      final pet = widget.controller.selectedPet;
      final date = widget.controller.selectedDate;

      if (pet == null) {
        print('선택된 펫이 없습니다.');
        return;
      }

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('사용자가 로그인되어 있지 않습니다.');
        return;
      }

      final trackingDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('pets')
          .doc(pet.id)
          .collection('tracking')
          .doc(date.toIso8601String().split('T').first);

      final docSnapshot = await trackingDocRef.get();

      if (docSnapshot.exists) {
        final waterData = await trackingDocRef.collection('water').get();
        final foodData = await trackingDocRef.collection('food').get();

        setState(() {
          waterGoal = (docSnapshot.get('waterGoal') as num).toInt();
          foodGoal = (docSnapshot.get('foodGoal') as num).toInt();

          currentWater = waterData.docs
              .fold(0, (sum, doc) => sum + (doc['volume'] as num).toInt());
          currentFood = foodData.docs
              .fold(0, (sum, doc) => sum + (doc['volume'] as num).toInt());

          print(
              '트래킹 데이터 로드 성공: waterGoal=$waterGoal, currentWater=$currentWater, foodGoal=$foodGoal, currentFood=$currentFood');
        });
      } else {
        setState(() {
          waterGoal = 0;
          foodGoal = 0;
          currentWater = 0;
          currentFood = 0;
        });
        print('트래킹 데이터 없음');
      }
    } catch (e) {
      print('트래킹 데이터를 로드하는 동안 오류 발생: $e');
    }
  }

/*
// class _TrackingGridState extends State<TrackingGrid> {
//   int waterGoal = 0;
//   int foodGoal = 0;
//   int currentWater = 0;
//   int currentFood = 0;
//   var trackingDocRef;
//   bool isLoading = true;

//   double currentWaterVolume = 0.0;
//   double currentFoodVolume = 0.0;
//   @override
//   void initState() {
//     super.initState();
//     _loadAllTrackingData();
//   }

//   Future<void> _loadAllTrackingData() async {
//     setState(() {
//       isLoading = true;
//     });

//     try {
//       await _initializeTrackingDocRef();

//       // trackingDocRef가 null이 아닐 때만 데이터를 로드합니다.
//       if (trackingDocRef != null) {
//         await _loadGoals();
//         await _loadCurrentWater();
//         await _loadCurrentFood();
//       } else {
//         print('trackingDocRef 초기화 실패.');
//       }
//     } catch (e) {
//       print("Error loading data: $e");
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> _initializeTrackingDocRef() async {
//     final pet = widget.controller.selectedPet;
//     final date = widget.controller.selectedDate;

//     // if (pet == null) {
//     //   print('선택된 펫이 없습니다.');
//     //   return;
//     // }

//     User? user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       print('사용자가 로그인되어 있지 않습니다.');
//       return;
//     }

//     trackingDocRef = FirebaseFirestore.instance
//         .collection('users')
//         .doc(user.uid)
//         .collection('pets')
//         .doc(pet?.id)
//         .collection('tracking')
//         .doc(date.toIso8601String().split('T').first);
//     print ('trackingDocRef 초기화 성공 : $trackingDocRef');
//   }

//   Future<void> _loadGoals() async {
//     final docSnapshot = await trackingDocRef.get();

//     if (docSnapshot.exists) {
//       waterGoal = (docSnapshot.get('waterGoal') as num).toInt();
//       foodGoal = (docSnapshot.get('foodGoal') as num).toInt();
//       print('Goals 로드 성공: waterGoal=$waterGoal, foodGoal=$foodGoal');
//     } else {
//       waterGoal = 0;
//       foodGoal = 0;
//       print('Goals 없음');
//     }
//   }

//   Future<void> _loadCurrentWater() async {
//     try {
//       if (trackingDocRef == null) {
//         print('trackingDocRef가 초기화되지 않았습니다.');
//         return;
//       }

//       final waterData = await trackingDocRef.collection('water').get();

//       setState(() {
//         currentWater = waterData.docs
//             .fold(0, (sum, doc) => sum + (doc['volume'] as num).toInt());
//         print('currentWater 로드 성공: currentWater=$currentWater');
//       });
//     } catch (e) {
//       print('currentWater 로드 중 오류 발생: $e');
//     }
//   }

//   Future<void> _loadCurrentFood() async {
//     try {
//       if (trackingDocRef == null) {
//         print('trackingDocRef가 초기화되지 않았습니다.');
//         return;
//       }

//       final foodData = await trackingDocRef.collection('food').get();

//       setState(() {
//         currentFood = foodData.docs
//             .fold(0, (sum, doc) => sum + (doc['volume'] as num).toInt());
//         print('currentFood 로드 성공: currentFood=$currentFood');
//       });
//     } catch (e) {
//       print('currentFood 로드 중 오류 발생: $e');
//     }
//   }
*/
  @override
  Widget build(BuildContext context) {
    double waterVolumeRatio = waterGoal > 0 ? currentWater / waterGoal : 0.0;
    double foodVolumeRatio = foodGoal > 0 ? currentFood / foodGoal : 0.0;
    print('믈 waterVolumeRatio: $waterVolumeRatio');
    print('사료 foodVolumeRatio: $foodVolumeRatio');
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        child: ListView(
          children: [
            // volume에 (현재기록량 / 목표량) 해서 소수점 한자릿수로 넣어주기 (0.0 ~ 1.0 범위)

            const SizedBox(height: 15),
            _buildTrackingItem(context, '물', volume: waterVolumeRatio),
            const SizedBox(height: 15),
            _buildTrackingItem(context, '사료', volume: foodVolumeRatio),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTrackingItem(context, '대변'),
                _buildTrackingItem(context, '구토'),
              ],
            ),
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
              colors: const [Color.fromARGB(255, 80, 155, 229), Colors.white],
              stops: [getVolume(), getVolume()],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(25),
          );
        case '사료':
          return BoxDecoration(
            gradient: LinearGradient(
              colors: const [Color.fromARGB(255, 124, 89, 61), Colors.white],
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
            date: widget.controller.selectedDate,
            petId: widget.controller.selectedPet!.id,
          );
          //await _loadCurrentWater(); // 업데이트 후 데이터를 다시 로드
          await _loadTrackingData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('물 1회차가 추가되었습니다.'),
              duration: Duration(seconds: 1), // 알림이 2초 동안 표시됩니다.
            ),
          );
          print('물 추가');
        } else if (title == '사료') {
          await saveFoodIntake(
            date: widget.controller.selectedDate,
            petId: widget.controller.selectedPet!.id,
          );
          //await _loadCurrentFood();
          await _loadTrackingData();

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
                      date: widget.controller.selectedDate,
                      petId: widget.controller.selectedPet!.id,
                    )),
          );
        } else if (title == '구토') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddVomitPage(
                      date: widget.controller.selectedDate,
                      petId: widget.controller.selectedPet!.id,
                    )),
          );
        }
      },
      child: Container(
        width: title == '물' || title == '사료' ? double.infinity : 182,
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
                            controller: widget.controller,
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
                ),
              if (title == '대변')
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 80,
                      child: Image.asset('assets/images/poop.png'),
                    ),
                  ],
                ),
              if (title == '구토')
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 80,
                      child: Image.asset('assets/images/vomit.png'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
