import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mncare/screens/tracking/tracking_info.dart';
import 'package:mncare/screens/tracking/tracking_screen_controller.dart';
import 'package:mncare/utilities/dailyWaterLogic.dart';
import 'package:mncare/utilities/dailyFoodLogic.dart' as FoodLogic;

class SetIntakeGoals extends StatefulWidget {
  final String title;
  final TrackingScreenController controller;

  const SetIntakeGoals({
    Key? key,
    required this.title,
    required this.controller,
  }) : super(key: key);
  @override
  _SetIntakeGoalsState createState() => _SetIntakeGoalsState();
}

class _SetIntakeGoalsState extends State<SetIntakeGoals> {
  int _dailyIntake = 0; // 초기값 설정
  int _dailyFrequency = 0; // 초기값 설정
  int _initialDailyIntake = 0; // 초기값 설정
  int _initialDailyFrequency = 0; // 초기값 설정
  int _foodKcal = 0;
  final TextEditingController _textController = TextEditingController();

  //petData
  bool isNeutered = false;
  double weight = 0.0;
  String petType = "강아지";

  int recommendedWaterIntake = 0;
  String recommendedWaterIntakeText = '';
  int recommendedFoodIntake = 0;
  String recommendedFoodIntakeText = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentGoals();
    _loadpetData();
  }

  String _getHeaderTitle() {
    if (widget.title == '물') {
      return '음수량';
    } else if (widget.title == '사료') {
      return '사료량';
    }
    return '';
  }

  Future<void> _loadCurrentGoals() async {
    final pet = widget.controller.selectedPet;
    final date = widget.controller.selectedDate;

    if (pet == null) return;

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final trackingDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('pets')
        .doc(pet.id)
        .collection('tracking')
        .doc(date.toIso8601String().split('T').first);

    final docSnapshot = await trackingDocRef.get();
    print('트래킹 intakedoc: ${docSnapshot.data()}');
    if (docSnapshot.exists) {
      setState(() {
        _initialDailyIntake = (docSnapshot
                .get(widget.title == '물' ? 'waterGoal' : 'foodGoal') as num)
            .toInt();
        _initialDailyFrequency =
            docSnapshot.get(widget.title == '물' ? 'waterCount' : 'foodCount');
        _foodKcal = docSnapshot.get('foodKcal') as int;
        _dailyIntake = _initialDailyIntake;
        _dailyFrequency = _initialDailyFrequency;
        _textController.text = _dailyIntake.toString();
        print(
            '트래킹 intakedoc: $_initialDailyIntake, $_initialDailyFrequency, foodKcal: $_foodKcal');
      });
    } else {
      // 초기화 값이 없을 경우

      setState(() {
        _dailyIntake = 0;
        _dailyFrequency = 0;
        _initialDailyIntake = 0;
        _initialDailyFrequency = 0;
        _textController.text = '0';
      });
    }
  }

  Future<void> _loadpetData() async {
    final pet = widget.controller.selectedPet;
    final date = widget.controller.selectedDate;

    if (pet == null) return;

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final petDataDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('pets')
        .doc(pet.id);
    try {
      final docSnapshot = await petDataDocRef.get();

      if (docSnapshot.exists) {
        setState(() {
          isNeutered = docSnapshot.get('isNeutered') as bool;
          weight = (docSnapshot.get('petWeight') as num).toDouble();
          petType = docSnapshot.get('petType') as String;
        });
      } else {
        print('해당 펫에 대한 데이터가 없습니다.');
      }
    } catch (e) {
      print('펫 데이터를 로드하는 동안 오류가 발생했습니다: $e');
    }

    final dateFormat = DateFormat('yyyy-MM-dd');
    final dateString = dateFormat.format(date); // selectedDate를 문자열로 변환
    final ageInMonths = calculateAgeInMonths(dateString);
    print('나이: $ageInMonths, 날짜: $dateString');

    // 하루 권장 음수량을 계산합니다.
    recommendedWaterIntake = calculateDailyWater(
      petType: petType, // 예: '고양이' 또는 '강아지'
      age: ageInMonths,
      weight: weight, // 펫의 몸무게
      isNeutered: isNeutered,
    ).toInt();
    recommendedFoodIntake = FoodLogic.calculateDailyFood(
      petType: petType, // 예: '고양이' 또는 '강아지'
      age: ageInMonths,
      weight: weight, // 펫의 몸무게
      isNeutered: isNeutered,
      defaultFoodKcal: _foodKcal,
    ).toInt();
    print(
        '트래킹 권장 음수량: $recommendedWaterIntake, 권장 사료량: $recommendedFoodIntake');
    recommendedFoodIntakeText = FoodLogic.getRecommendedFoodIntakeText(
        petType, ageInMonths, isNeutered);

    recommendedWaterIntakeText =
        getRecommendedWaterIntakeText(petType, ageInMonths, isNeutered);
  }

  void _showRecommendedWaterInfo() {
    print('트래킹 showRecommendedWaterInfo호출');
    final pet = widget.controller.selectedPet;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '적정 음수량 안내',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  recommendedWaterIntakeText,
                  //'[하루 적정 음수량 = 몸무게(kg) X 20~70ml]',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${weight}kg ${pet?.name}에겐 ${recommendedWaterIntake}ml를 권장해요',
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                '적정 음수량은 건식 사료를 기준으로 안내하고 있어요. 음수량은 활동량, 나이, 날씨, 급여하는 음식의 형태에 따라 약간의 차이가 발생할 수 있어요.',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 10),
              const Text(
                '혹시 아이의 몸무게에 변화가 있다면 [기록 > 몸무게 > 새로운 기록 추가하기] 에서 추가해주세요.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRecommendedFoodInfo() {
    print('트래킹 showRecommendedFoodInfo호출');
    final pet = widget.controller.selectedPet;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '적정 사료량 안내',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  recommendedFoodIntakeText,
                  //'[하루 적정 음수량 = 몸무게(kg) X 20~70ml]',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${weight}kg ${pet?.name}에겐 ${recommendedFoodIntake}g를 권장해요',
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                '적정 사료량은 건식 사료를 기준으로 안내하고 있어요. 사료량은 활동량, 나이, 날씨, 급여하는 음식의 형태에 따라 약간의 차이가 발생할 수 있어요.',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 10),
              const Text(
                '혹시 아이의 몸무게에 변화가 있다면 [기록 > 몸무게 > 새로운 기록 추가하기] 에서 추가해주세요.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  //수정한 목표를 DB에 저장하는 부분.
  Future<void> _saveGoal() async {
    final pet = widget.controller.selectedPet;
    final date = widget.controller.selectedDate;

    if (pet == null) return;

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final trackingDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('pets')
        .doc(pet.id)
        .collection('tracking')
        .doc(date.toIso8601String().split('T').first);

    await trackingDocRef.update({
      widget.title == '물' ? 'waterGoal' : 'foodGoal': _dailyIntake,
      widget.title == '물' ? 'waterCount' : 'foodCount': _dailyFrequency,
    });

    print("목표 설정이 성공적으로 저장되었습니다.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '목표 ${_getHeaderTitle()} 설정',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1일 목표 ${_getHeaderTitle()}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            if (widget.title == '물')
                              Text(
                                  //'권장 음수량: 90~315ml/일', // 이거 해당 동물 데이터로 계산해서 값 보여주게 수정
                                  '권장 음수량: ${recommendedWaterIntake}ml/일',
                                  style: const TextStyle(
                                      color: Colors.blue, fontSize: 14)),
                            if (widget.title == '물')
                              IconButton(
                                icon: const Icon(Icons.info_outline,
                                    color: Colors.blue, size: 18),
                                onPressed: _showRecommendedWaterInfo,
                              ),
                            if (widget.title == '사료')
                              Text(
                                  '권장 사료량: ${recommendedFoodIntake}g/일', // 이거 해당 동물 데이터로 계산해서 값 보여주게 수정
                                  style: const TextStyle(
                                      color: Colors.blue, fontSize: 14)),
                            if (widget.title == '사료')
                              IconButton(
                                icon: const Icon(Icons.info_outline,
                                    color: Colors.blue, size: 18),
                                onPressed: _showRecommendedFoodInfo,
                              ),
                          ],
                        ),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
                        child: TextField(
                          controller: _textController,
                          maxLines: 1,
                          textAlign: TextAlign.right,
                          keyboardType: TextInputType.number,
                          cursorColor: Colors.black,
                          decoration: const InputDecoration(
                            hintText: '0',
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _dailyIntake =
                                  int.tryParse(value) ?? _dailyIntake;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    if (widget.title == '물')
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 50),
                        child: Text(
                          'ml',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (widget.title == '사료')
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 50),
                        child: Text(
                          'g',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(width: 15),
                  ],
                ),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '1일 섭취 횟수',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          '1회 기본 양 : ${_dailyFrequency > 0 ? (_dailyIntake / _dailyFrequency).round() : 0}ml씩',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                          padding: const EdgeInsets.fromLTRB(115, 0, 0, 40),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  if (_dailyFrequency > 1) {
                                    setState(() {
                                      _dailyFrequency--;
                                    });
                                  }
                                },
                              ),
                              Text('$_dailyFrequency회',
                                  style: const TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                  )),
                              IconButton(
                                icon: const Icon(
                                  Icons.add_circle,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _dailyFrequency++;
                                  });
                                },
                              ),
                            ],
                          )),
                    ),
                  ],
                ),
              ],
            ),
            _buildCompleteButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleteButton() {
    bool isChanged = _dailyIntake != _initialDailyIntake ||
        _dailyFrequency != _initialDailyFrequency;
    return ElevatedButton(
      onPressed: isChanged
          ? () async {
              await _saveGoal();
              Navigator.of(context).pop({'updated': true});
            }
          : null,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: isChanged
            ? const Color.fromARGB(255, 235, 91, 0)
            : const Color.fromARGB(255, 222, 222, 222),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        minimumSize: const Size(double.infinity, 55),
      ),
      child: const Text(
        '완료',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
