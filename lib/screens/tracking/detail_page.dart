import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mncare/screens/tracking/add_%20poop_page.dart';
import 'package:mncare/screens/tracking/add_food_page.dart';
import 'package:mncare/screens/tracking/add_vomit_page.dart';
import 'package:mncare/screens/tracking/add_water_page.dart';
import 'package:mncare/screens/tracking/set_intake_goals.dart';
import 'package:mncare/screens/tracking/tracking_screen_controller.dart';
import 'package:mncare/utilities/utils.dart';

import 'tracking_info.dart';

class DetailPage extends StatefulWidget {
  final String title;
  final TrackingScreenController controller;

  const DetailPage({
    Key? key,
    required this.title,
    required this.controller,
  }) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

double _getContainerHeight(String title) {
  if (title == '물' || title == '사료') {
    return 494;
  } else {
    return 684;
  }
}

class _DetailPageState extends State<DetailPage> {
  int current = 0; // 초기값을 0으로 설정
  int waterGoal = 0; // waterGoal 초기값을 0으로 설정
  int waterCount = 0;
  int foodGoal = 0; // waterGoal 초기값을 0으로 설정
  int foodCount = 0;
  late String engTitle;

  User? user = FirebaseAuth.instance.currentUser;
  // ignore: prefer_typing_uninitialized_variables
  var trackingDocRef; // trackingDocRef 초기값을 null로 설정 // 현재 트래킹 DB 참조
  List<dynamic> intakeList = [];

  @override
  void initState() {
    super.initState();

    if (widget.title == "물") {
      engTitle = "water";
    } else if (widget.title == "사료") {
      engTitle = "food";
    } else if (widget.title == "대변") {
      engTitle = "poop";
    } else if (widget.title == "구토") {
      engTitle = "vomit";
    } else {
      engTitle = ""; // 필요한 경우 기본값 설정
    }
    print('트래킹 데이터 로드');
    _loadTrackingData(); // 페이지 초기화 시 트래킹 데이터 로드
    if (widget.title == '물') {
      _loadWaterIntake();
    } else if (widget.title == '사료') {
      _loadFoodIntake();
    } else if (widget.title == '대변') {
      _loadPoopIntake();
    } else if (widget.title == '구토') {
      _loadVomitIntake();
    }
  }

  Future<void> _loadWaterIntake() async {
    try {
      final collectionRef = trackingDocRef.collection('water');

      final querySnapshot = await collectionRef.get();

      if (querySnapshot.docs.isEmpty) {
        print('물 기록이 없습니다.');
      } else {
        print('물 기록을 로드했습니다: ${querySnapshot.docs.length}개');
      }

      setState(() {
        intakeList = querySnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'timestamp': doc['timestamp'], // 타임스탬프
            'volume': doc['volume'], // 음수량
          };
        }).toList(); // as List<dynamic>; // 명시적인 타입 캐스팅은 생략
        intakeList.sort((a, b) => (a['timestamp'] as Timestamp)
            .compareTo(b['timestamp'] as Timestamp));

        current = intakeList.fold(
            0, (sum, item) => sum + (item['volume'] as num).toInt());
      });
    } catch (e) {
      print('물 기록을 로드하는 동안 오류 발생: $e');
    }
  }

  Future<void> _loadFoodIntake() async {
    try {
      final collectionRef = trackingDocRef.collection('food');
      final querySnapshot = await collectionRef.get();

      if (querySnapshot.docs.isEmpty) {
        print('사료 기록이 없습니다.');
      } else {
        print('사료 기록을 로드했습니다: ${querySnapshot.docs.length}개');
      }

      setState(() {
        intakeList = querySnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'timestamp': doc['timestamp'], // 타임스탬프
            'volume': doc['volume'], // 사료량
          };
        }).toList();

        intakeList.sort((a, b) => (a['timestamp'] as Timestamp)
            .compareTo(b['timestamp'] as Timestamp));

        current = intakeList.fold(
            0, (sum, item) => sum + (item['volume'] as num).toInt());
      });
    } catch (e) {
      print('사료 기록을 로드하는 동안 오류 발생: $e');
    }
  }

  Future<void> _loadPoopIntake() async {
    try {
      final collectionRef = trackingDocRef.collection('poop');

      final querySnapshot = await collectionRef.get();

      if (querySnapshot.docs.isEmpty) {
        print('대변 기록이 없습니다.');
      } else {
        print('대변 기록을 로드했습니다: ${querySnapshot.docs.length}개');
      }

      setState(() {
        intakeList = querySnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'timestamp': doc['timestamp'], // 타임스탬프
            'shape': doc['shape'], // 대변 형태
            'color': doc['color'], // 대변 색상
            'memo': doc['memo'], // 메모
          };
        }).toList();
        intakeList.sort((a, b) => (a['timestamp'] as Timestamp)
            .compareTo(b['timestamp'] as Timestamp));
      });
    } catch (e) {
      print('대변 기록을 로드하는 동안 오류 발생: $e');
    }
  }

  Future<void> _loadVomitIntake() async {
    try {
      final collectionRef = trackingDocRef.collection('vomit');

      final querySnapshot = await collectionRef.get();

      if (querySnapshot.docs.isEmpty) {
        print('구토 기록이 없습니다.');
      } else {
        print('구토 기록을 로드했습니다: ${querySnapshot.docs.length}개');
      }

      setState(() {
        intakeList = querySnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'timestamp': doc['timestamp'],
            'shape': doc['shape'],
            'memo': doc['memo'],
          };
        }).toList();
        intakeList.sort((a, b) => (a['timestamp'] as Timestamp)
            .compareTo(b['timestamp'] as Timestamp));
      });
    } catch (e) {
      print('구토 기록을 로드하는 동안 오류 발생: $e');
    }
  }

  //물 추가시에 업데이트 상태 반영
  Future<void> _navigateToAddWaterPage(int waterCount, int waterGoal) async {
    bool? updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddWaterPage(
          date: widget.controller.selectedDate,
          petId: widget.controller.selectedPet!.id,
          waterCount: waterCount,
          waterGoal: waterGoal,
        ),
      ),
    );

    if (updated == true) {
      await _loadWaterIntake(); // 추가된 데이터를 로드하여 current를 업데이트
      setState(() {
        _loadTrackingData(); // 페이지를 다시 로드하여 데이터 업데이트
      });
    }
  }

  //사료 추가시에 업데이트 상태 반영
  Future<void> _navigateToAddFoodPage(int foodCount, int foodGoal) async {
    bool? updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFoodPage(
          date: widget.controller.selectedDate,
          petId: widget.controller.selectedPet!.id,
          foodCount: foodCount,
          foodGoal: foodGoal,
        ),
      ),
    );

    if (updated == true) {
      await _loadFoodIntake(); // 추가된 데이터를 로드하여 current를 업데이트
      setState(() {
        _loadTrackingData(); // 페이지를 다시 로드하여 데이터 업데이트
      });
    }
  }

  Future<void> _navigateToAddPoopPage() async {
    bool? updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPoopPage(
          date: widget.controller.selectedDate,
          petId: widget.controller.selectedPet!.id,
        ),
      ),
    );

    if (updated == true) {
      await _loadPoopIntake(); // 추가된 데이터를 로드하여 current를 업데이트
      setState(() {
        _loadTrackingData(); // 페이지를 다시 로드하여 데이터 업데이트
      });
    }
  }

  Future<void> _navigateToAddVomitPage() async {
    bool? updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddVomitPage(
          date: widget.controller.selectedDate,
          petId: widget.controller.selectedPet!.id,
        ),
      ),
    );

    if (updated == true) {
      await _loadVomitIntake(); // 추가된 데이터를 로드하여 current를 업데이트
      setState(() {
        _loadTrackingData(); // 페이지를 다시 로드하여 데이터 업데이트
      });
    }
  }

  Future<void> _loadTrackingData() async {
    try {
      final pet = widget.controller.selectedPet;
      final date = widget.controller.selectedDate;

      if (pet == null) {
        print('선택된 펫이 없습니다.');
        return;
      }
      if (user == null) {
        print('사용자가 로그인되어 있지 않습니다.');
        return;
      }

      trackingDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('pets')
          .doc(pet.id)
          .collection('tracking')
          .doc(date.toIso8601String().split('T').first);

      final docSnapshot = await trackingDocRef.get();

      if (docSnapshot.exists) {
        setState(() {
          //current = ; 각회차에 대해서 전부 더한거.
          waterGoal = (docSnapshot.get('waterGoal') as num).toInt();
          waterCount = (docSnapshot.get('waterCount') as num).toInt();
          foodGoal = (docSnapshot.get('foodGoal') as num).toInt();
          foodCount = (docSnapshot.get('foodCount') as num).toInt();
          print(
              '트래킹 데이터 로드 성공: waterGoal=$waterGoal, waterCount=$waterCount, foodGoal=$foodGoal, foodCount=$foodCount');
        });
      } else {
        setState(() {
          waterGoal = 0;
        });
        print('트래킹 데이터 없음');
      }
    } catch (e) {
      print('트래킹 데이터를 로드하는 동안 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
          child: Column(
        children: [
          if (widget.title == '물' || widget.title == '사료') // 물이나 사료인 경우에만 띄우기
            SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.title == '물')
                    Text(
                      "${current}/${waterGoal}ml",
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.w500),
                    ),
                  if (widget.title == '사료')
                    Text(
                      "${current}/${foodGoal}g",
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.w500),
                    ),
                ],
              ),
            ),
          if (widget.title == '물' ||
              widget.title == '사료') // 물이나 사료인 경우에만 섭취루틴 띄우기
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
              child: Container(
                width: double.infinity,
                height: 105,
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 15),
                decoration: BoxDecoration(
                  border: Border.all(
                      width: 1.5,
                      color: const Color.fromARGB(255, 240, 240, 240)),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '1일 섭취 루틴',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SetIntakeGoals(
                                  title: widget.title,
                                  controller: widget.controller,
                                ),
                              ),
                            ).then((result) {
                              if (result != null && result['updated'] == true) {
                                setState(() {
                                  _loadTrackingData(); // 데이터를 다시 로드하여 업데이트
                                  //좀 느린거 같은데,
                                });
                              }
                            });
                          }, // 1일 섭취 루틴 수정 창으로 이동
                          icon: const Icon(Icons.edit),
                          iconSize: 20,
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            const Text(
                              '목표량',
                              style: TextStyle(
                                color: Color.fromARGB(255, 80, 80, 80),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Row(
                              children: [
                                if (widget.title == '물')
                                  Text(
                                    "${waterGoal}ml", // 데이터 가져와서 띄우게 수정
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                if (widget.title == '사료')
                                  Text(
                                    "${foodGoal}g", // 데이터 가져와서 띄우게 수정
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              '목표 횟수',
                              style: TextStyle(
                                color: Color.fromARGB(255, 80, 80, 80),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Row(
                              children: [
                                if (widget.title == '물')
                                  Text(
                                    "$waterCount", // 데이터 가져와서 띄우게 수정
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                if (widget.title == '사료')
                                  Text(
                                    "$foodCount", // 데이터 가져와서 띄우게 수정
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          if (widget.title == '물' ||
              widget.title == '사료') // 물이나 사료인 경우에만 여백 띄우기
            Container(
              height: 10,
              color: const Color.fromARGB(255, 240, 240, 240),
            ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: GestureDetector(
              onTap: () {
                if (widget.title == '물') {
                  if (widget.controller.selectedPet != null) {
                    _navigateToAddWaterPage(waterCount, waterGoal); //
                  } else {
                    // selectedPet이 null인 경우 예외 처리
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("선택된 펫이 없습니다.")),
                    );
                  }
                }
                if (widget.title == '사료') {
                  if (widget.controller.selectedPet != null) {
                    _navigateToAddFoodPage(foodCount, foodGoal); //
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("선택된 펫이 없습니다.")),
                    );
                  }
                }
                if (widget.title == '대변') {
                  if (widget.controller.selectedPet != null) {
                    _navigateToAddPoopPage();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("선택된 펫이 없습니다.")),
                    );
                  }
                }
                if (widget.title == '구토') {
                  if (widget.controller.selectedPet != null) {
                    _navigateToAddVomitPage();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("선택된 펫이 없습니다.")),
                    );
                  }
                }
              }, // 기록 추가 로직으로 수정
              child: Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 178, 0),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '기록 추가하기',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          //이 뒤에 부터는 리스트로 기록들 불수 있도록
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
            child: Container(
              width: double.infinity,
              height: _getContainerHeight(widget.title),
              padding: const EdgeInsets.fromLTRB(25, 12.5, 25, 12.5),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 240, 240, 240),
                borderRadius: BorderRadius.circular(25),
              ),
              child: intakeList.isEmpty // 데이터 가져와서 검사하게 수정
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.folder_outlined,
                            size: 50,
                            color: Color.fromARGB(255, 120, 120, 120),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '기록이 없습니다',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: intakeList.length, // 데이터 가져오게 수정
                      itemBuilder: (context, index) {
                        final intake = intakeList[
                            index]; // intake는 Map<String, dynamic> 타입입니다.
                        int volume = 0;
                        if (widget.title == '물' || widget.title == '사료') {
                          volume = (intake['volume'] as num)
                              .toInt(); // 'volume' 키에 해당하는 값을 추출합니다.
                        }
                        final timestamp = intake[
                            'timestamp']; // 'timestamp' 키에 해당하는 값을 추출합니다.

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(0, 12.5, 0, 12.5),
                          child: Container(
                            width: double.infinity,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    if (widget.title == '물' ||
                                        widget.title == '사료')
                                      Text(
                                        '${index + 1}회차', // 회차
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    if (widget.title == '구토' ||
                                        widget.title == '대변')
                                      Text(
                                        '${intake['shape']}', //대변의 경우 모양
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    if (!(widget.title == '구토'))
                                      const Text(
                                        '  ·  ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    if (widget.title == '물' ||
                                        widget.title == '사료')
                                      Text(
                                        '$volume', // 데이터 가져와서 띄우게 수정
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    if (widget.title == '대변')
                                      Container(
                                        width: 20, // 원형의 크기
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: getColorFromString(intake[
                                              'color']), // 색상을 문자열에서 가져와서 사용
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    if (widget.title == '물')
                                      const Text(
                                        'ml',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    if (widget.title == '사료')
                                      const Text(
                                        'g',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400),
                                      ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        await trackingDocRef
                                            .collection(
                                                engTitle) // Adjust as needed
                                            .doc(intake['id'])
                                            .delete();

                                        setState(() {
                                          intakeList.removeAt(index);
                                        });

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  "Record deleted successfully.")),
                                        );

                                        await _loadTrackingData();

                                        if (engTitle == 'water') {
                                          await _loadWaterIntake();
                                        } else if (engTitle == 'food') {
                                          await _loadFoodIntake();
                                        } else if (engTitle == 'poop') {
                                          await _loadPoopIntake();
                                        } else if (engTitle == 'vomit') {
                                          await _loadVomitIntake();
                                        }
                                      },
                                      icon: const Icon(Icons.delete),
                                      color: Colors.grey,
                                    ),
                                    //회차 수정 로직
                                    IconButton(
                                      onPressed: () async {
                                        var wasUpdated = false;
                                        if (widget.title == '물') {
                                          wasUpdated = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AddWaterPage(
                                                date: widget
                                                    .controller.selectedDate,
                                                petId: widget
                                                    .controller.selectedPet!.id,
                                                waterCount: waterCount,
                                                waterGoal: waterGoal,
                                                existingRecord: intake,
                                              ),
                                            ),
                                          );
                                        } else if (widget.title == '사료') {
                                          wasUpdated = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AddFoodPage(
                                                date: widget
                                                    .controller.selectedDate,
                                                petId: widget
                                                    .controller.selectedPet!.id,
                                                foodCount: foodCount,
                                                foodGoal: foodGoal,
                                                existingRecord: intake,
                                              ),
                                            ),
                                          );
                                        } else if (widget.title == '대변') {
                                          wasUpdated = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AddPoopPage(
                                                date: widget
                                                    .controller.selectedDate,
                                                petId: widget
                                                    .controller.selectedPet!.id,
                                                existingRecord: intake,
                                              ),
                                            ),
                                          );
                                        } else if (widget.title == '구토') {
                                          wasUpdated = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AddVomitPage(
                                                date: widget
                                                    .controller.selectedDate,
                                                petId: widget
                                                    .controller.selectedPet!.id,
                                                existingRecord: intake,
                                              ),
                                            ),
                                          );
                                        }

                                        if (wasUpdated == true) {
                                          setState(() {
                                            if (widget.title == '물') {
                                              _loadWaterIntake();
                                            } else if (widget.title == '사료') {
                                              _loadFoodIntake();
                                            } else if (widget.title == '대변') {
                                              _loadPoopIntake();
                                            } else if (widget.title == '구토') {
                                              _loadVomitIntake();
                                            }
                                          });

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    "Record updated successfully.")),
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.edit),
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(
                                      width: 7,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          )
        ],
      )),
    );
  }
}
