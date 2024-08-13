//해당 펫의 종족, 나이, 몸무게의 정보를 받아 하루에 필요한 물의 양을 계산하는 함수

double calculateDailyWater({
  required String petType,
  required int age, // in months
  required double weight,
  required bool isNeutered,
}) {
  double dailyWaterAmount = 0.0; // 하루 음수량(ml)

  if (petType == "고양이") {
    // 고양이의 경우
    if (age < 12) {
      // 새끼 고양이 (1살 미만, 12개월 미만)
      dailyWaterAmount = weight * 60; // 체중(kg)당 60ml의 물 권장
    } else {
      // 성묘
      dailyWaterAmount = weight * 50; // 체중(kg)당 50ml의 물 권장
    }
  } else if (petType == "강아지") {
    // 강아지의 경우
    if (age <= 4) {
      dailyWaterAmount = weight * 80; // 체중(kg)당 80ml의 물 권장
    } else if (age <= 12) {
      dailyWaterAmount = weight * 70; // 체중(kg)당 70ml의 물 권장
    } else {
      if (isNeutered) {
        dailyWaterAmount = weight * 55; // 체중(kg)당 55ml의 물 권장 (중성화된 성견)
      } else {
        dailyWaterAmount = weight * 65; // 체중(kg)당 65ml의 물 권장 (중성화되지 않은 성견)
      }
    }
  }

  return dailyWaterAmount; // 하루 음수량(ml)
}

int calculateAgeInMonths(String birthDate) {
  final birth = DateTime.parse(birthDate);
  final now = DateTime.now();
  final age = now.year * 12 + now.month - (birth.year * 12 + birth.month);
  return age;
}

String getRecommendedWaterIntakeText(String petType, int age, bool isNeutered) {
  if (petType == "고양이") {
    // if (age < 12) {
    //   return '[12개월 이하의 하루 적정 음수량 = 몸무게(kg) X 60ml]';
    // } else {
    //   return '[하루 적정 음수량 = 몸무게(kg) X 50ml]';
    // }
    return 
        '[성묘 고양이의 하루 적정 음수량 = 몸무게(kg) X 50ml]'; // 오류 처리, 디폴트
  } else if (petType == "강아지") {
    if (age <= 4) {
      return '[하루 적정 음수량 = 몸무게(kg) X 80ml]';
    } else if (age <= 12) {
      return '[하루 적정 음수량 = 몸무게(kg) X 70ml]';
    } else {
      if (isNeutered) {
        return '[하루 적정 음수량 = 몸무게(kg) X 55ml]';
      } else {
        return '[하루 적정 음수량 = 몸무게(kg) X 65ml]';
      }
    }
  }
  return '[하루 적정 음수량 = 몸무게(kg) X ?ml]'; // 오류 처리, 디폴트
}
