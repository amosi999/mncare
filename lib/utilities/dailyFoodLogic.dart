//해당 펫의 고양이인지 강아지 인지 String으로, 나이 num, 몸무게 double, 사료칼로리 int kcal/kg단위, 중성화 여부 bool, 5가지의 의 정보를 받아 하루에 필요한 영양소를 계산하는 함수
double calculateDailyFood({
  required String petType,
  required int age, // in months
  required double weight,
  required int defaultFoodKcal,
  required bool isNeutered,
}) {
  double RER; // Resting Energy Requirement (기초 대사량)
  double DER; // Daily Energy Requirement (일일 에너지 요구량)
  double dailyFoodAmount = 0.0; // 하루 사료량(g)

  if (petType == "고양이") {
    // 고양이의 경우
    if (weight < 2.0) {
      RER = 70 * (weight * 0.75);
    } else {
      RER = 30 * weight + 70;
    }

    if (age < 12) {
      // 새끼 고양이 (1살 미만, 12개월 미만)
      DER = RER * 2.5; // 새끼 고양이의 경우 가중치 2.5 사용
    } else if (isNeutered) {
      // 중성화한 보통 활동량의 고양이
      DER = RER * 1.2;
    } else {
      // 과체중 또는 활동량이 적은 고양이
      DER = RER * 1.0;
    }

    dailyFoodAmount = (DER / defaultFoodKcal) * 1000;
  } else if (petType == "강아지") {
    // 강아지의 경우
    //RER = 70 * 0.75 * 0.75; // RER 계산
    RER = weight * 30 + 70; // RER 계산

    // if (age <= 3) {
    //   DER = weight * 0.05; // 3개월 이하 체중의 5%
    // } else if (age <= 6) {
    //   DER = weight * 0.04; // 3개월 초과 6개월 이하의 강아지 체중의 4%
    // } else if (age <= 12) {
    //   DER = weight * 0.03; // 6개월 초과 12개월 이하의 강아지 체중의 3%
    // }
    if (age < 4) {
      DER = RER * 3.0; // 3개월 미만 강아지
    } else if (age < 12) {
      DER = RER * 2.0; // 3개월 이상 12개월 미만 강아지
    } else {
      if (isNeutered) {
        DER = RER * 1.6; // 중간 활동량, 중성화된 성견
      } else {
        DER = RER * 1.8; // 중간 활동량, 중성화되지 않은 성견
      }
    }

    dailyFoodAmount = (DER / defaultFoodKcal) * 1000;
  }

  return dailyFoodAmount; // 하루 사료량(g)
}

int calculateAgeInMonths(String birthDate) {
  final birth = DateTime.parse(birthDate);
  final now = DateTime.now();
  final age = now.year * 12 + now.month - (birth.year * 12 + birth.month);
  return age;
}
