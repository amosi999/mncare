// 트래킹 상세보기 창을 위한 더미 데이터
List<String> trackingExList = ['1회차', '2회차', '3회차', '4회차', '5회차'];
// List<String> trackingExList = [];

class Pet {
  final String id;
  final String name;
  final String? breed;
  final String? gender;
  final DateTime? birthDate;
  final double? weight;
  final String? otherDetails;

  Pet({
    required this.id,
    required this.name,
    this.breed,
    this.gender,
    this.birthDate,
    this.weight,
    this.otherDetails,
  });

  // Add other utility methods or data handling functions if needed
}