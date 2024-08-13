import 'package:flutter/material.dart';

class SetIntakeGoals extends StatefulWidget {
  final String title;

  const SetIntakeGoals({super.key, required this.title});

  @override
  _SetIntakeGoalsState createState() => _SetIntakeGoalsState();
}

class _SetIntakeGoalsState extends State<SetIntakeGoals> {
  // 이거 동물 별 데이터 가져오게 수정
  int _dailyIntake = 202;
  int _dailyFrequency = 3;
  int _initialDailyIntake = 202;
  int _initialDailyFrequency = 3;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textController.text = _dailyIntake.toString();
    _initialDailyIntake = _dailyIntake;
    _initialDailyFrequency = _dailyFrequency;
  }

  String _getHeaderTitle() {
    if (widget.title == '물') {
      return '음수량';
    } else if (widget.title == '사료') {
      return '사료량';
    }
    return '';
  }

  void _showRecommendedWaterIntakeInfo() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '권장 음수량 안내',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    '[하루 적정 음수량 = 몸무게(kg) X 20~70ml]',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '4.5kg 머루에겐 90~315ml를 권장해요', // 위의 식 활용해서 데이터 가져와서 ${data}로 문자열에 집어넣게 수정
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                '적정 음수량은 건식 사료를 기준으로 안내하고 있어요. 음수량은 활동량, 나이, 날씨, 급여하는 음식의 형태에 따라 약간의 차이가 발생할 수 있어요.',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 10),
              const Text(
                '혹시 아이의 몸무게에 변화가 있다면 마이 페이지의 반려동물 정보 수정에서 정보를 수정해주세요.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRecommendedFoodIntakeInfo() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '권장 사료량 안내',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                '권장 사료량은 건식 사료를 기준으로 현재의 나이, 몸무게, 중성화 여부를 고려해 안내하고 있어요. 다만 반려동물마다 대사량, 활동량이 다르기 때문에 체중이 늘어나는지 줄어드는지에 따라 사료량을 적절히 조절하면서 급여하는 게 좋아요.',
                style: TextStyle(fontSize: 15),
              ),
              Divider(
                color: Colors.grey,
                thickness: 0.5,
                height: 40,
              ),
              Text(
                '성장기 아이',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                '자라나는 성장 시기에는 꾸준히 체중이 늘어나야 해요. 체중이 유지되거나 오히려 줄었다면 근육, 뼈 등이 제대로 성장할 수 없기 때문에 꼭 사료량을 늘려 급여해주세요.',
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(height: 20),
              Text(
                '성장기가 막 끝난 아이 (10~12개월)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                '성장기가 끝나면 자연스럽게 먹는 양이 줄어요. 급여량이 줄어도 체중이 유지된다면 정상. 체중이 오히려 줄어들었다면 아이의 건강 이상을 의심해 봐야 해요.',
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(height: 20),
              Text(
                '성견/성묘인 아이 (12개월 이후)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                '매우 야위었거나 비만이 아니라면 체중이 일정하게 유지되는 것이 좋아요. 혹시 아이가 공복에 노란색 토를 자주 한다면 공복시간이 긴 탓일 수 있으니 급여 횟수를 조금 늘리고, 변이 묽다면 사료량을 줄여보세요. 그래도 증상이 호전되지 않는다면 병원 상담을 추천해요.',
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
        );
      },
    );
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
                              const Text(
                                  '권장 음수량: 90~315ml/일', // 이거 해당 동물 데이터로 계산해서 값 보여주게 수정
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 14)),
                            if (widget.title == '사료')
                              const Text(
                                  '권장 사료량: 140g/일', // 이거 해당 동물 데이터로 계산해서 값 보여주게 수정
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 14)),
                            if (widget.title == '물')
                              IconButton(
                                icon: const Icon(Icons.info_outline,
                                    color: Colors.blue, size: 18),
                                onPressed: _showRecommendedWaterIntakeInfo,
                              ),
                            if (widget.title == '사료')
                              IconButton(
                                icon: const Icon(Icons.info_outline,
                                    color: Colors.blue, size: 18),
                                onPressed: _showRecommendedFoodIntakeInfo,
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
                        SizedBox(
                          width: 220,
                          child: Text(
                            '1회 기본 양 : ${(_dailyIntake / _dailyFrequency).round()}ml씩',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                          padding: const EdgeInsets.fromLTRB(2, 0, 0, 40),
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
          ? () {
              // 데이터 변경 로직으로 수정
              Navigator.of(context).pop();
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
