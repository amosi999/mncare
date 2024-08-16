import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mncare/screens/calendar/schedule_info.dart';
import 'package:mncare/screens/calendar/schedule_type_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedPetId;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('pets')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('반려동물 정보가 없습니다.'));
            }

            var pets = snapshot.data!.docs;
            if (selectedPetId == null ||
                !pets.any((pet) => pet.id == selectedPetId)) {
              selectedPetId = pets.first.id;
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPetProfile(colorScheme, pets),
                    const SizedBox(height: 16),
                    _buildInfoCards(colorScheme, selectedPetId!),
                    const SizedBox(height: 16),
                    _buildCountInfoCard(colorScheme, selectedPetId!),
                    const SizedBox(height: 16),
                    _buildCareSchedule(colorScheme),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPetProfile(
      ColorScheme colorScheme, List<QueryDocumentSnapshot> pets) {
    var selectedPet = pets.firstWhere((pet) => pet.id == selectedPetId);
    var petData = selectedPet.data() as Map<String, dynamic>;

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.background,
                radius: 30,
                child: Icon(Icons.pets, color: colorScheme.onBackground),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${petData['petName']} (${petData['petGender']}) | ${_calculateAge(petData['petBirthDate'])}',
                      style: TextStyle(
                          color: colorScheme.onPrimaryContainer, fontSize: 18),
                    ),
                    Text(
                      '${petData['petType']} - ${petData['petBreed']}',
                      style: TextStyle(
                          color:
                              colorScheme.onPrimaryContainer.withOpacity(0.7)),
                    ),
                    Text(
                      '${petData['petWeight']}kg | ${petData['isNeutered'] ? '중성화 O' : '중성화 X'}',
                      style: TextStyle(
                          color:
                              colorScheme.onPrimaryContainer.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (pets.length > 1)
          Positioned(
            top: 8,
            right: 8,
            child: PopupMenuButton<String>(
              icon:
                  Icon(Icons.more_vert, color: colorScheme.onPrimaryContainer),
              onSelected: (String petId) {
                setState(() {
                  selectedPetId = petId;
                });
              },
              itemBuilder: (BuildContext context) {
                return pets.map((pet) {
                  var petData = pet.data() as Map<String, dynamic>;
                  return PopupMenuItem<String>(
                    value: pet.id,
                    child: Text(petData['petName']),
                  );
                }).toList();
              },
            ),
          ),
      ],
    );
  }

  Widget _buildInfoCards(ColorScheme colorScheme, String petId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('pets')
          .doc(petId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('반려동물 정보를 찾을 수 없습니다.'));
        }

        var petData = snapshot.data!.data() as Map<String, dynamic>;
        var etcInfo = petData['etc'] as String? ?? '없음';

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('pets')
              .doc(petId)
              .collection('petDoctor')
              .orderBy('createdDate', descending: true)
              .limit(1)
              .snapshots(),
          builder: (context, diagnosisSnapshot) {
            String lastDiagnosisText = '정보 없음';
            if (diagnosisSnapshot.connectionState == ConnectionState.waiting) {
              lastDiagnosisText = '로딩 중...';
            } else if (diagnosisSnapshot.hasError) {
              lastDiagnosisText = '오류 발생';
            } else if (diagnosisSnapshot.hasData &&
                diagnosisSnapshot.data!.docs.isNotEmpty) {
              var diagnosisData = diagnosisSnapshot.data!.docs.first.data()
                  as Map<String, dynamic>;
              lastDiagnosisText = DateFormat('yyyy-MM-dd')
                  .format((diagnosisData['createdDate'] as Timestamp).toDate());
            }

            return Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                      '특이사항', etcInfo, Icons.info_outline, colorScheme),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard('마지막 진단 날짜', lastDiagnosisText,
                      Icons.medical_services, colorScheme),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildInfoCard(
      String title, String subtitle, IconData icon, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(height: 8),
          Text(title,
              style:
                  TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface)),
        ],
      ),
    );
  }

  Widget _buildCountInfoCard(ColorScheme colorScheme, String petId) {
  final now = DateTime.now();
  final today = DateFormat('yyyy-MM-dd').format(now);

  return StreamBuilder<Map<String, int>>(
    stream: Rx.combineLatest4(
      _getCollectionCount(petId, today, 'water'),
      _getCollectionCount(petId, today, 'food'),
      _getCollectionCount(petId, today, 'poop'),
      _getCollectionCount(petId, today, 'vomit'),
      (water, food, poop, vomit) => {
        'water': water,
        'food': food,
        'poop': poop,
        'vomit': vomit,
      },
    ),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      }

      final counts = snapshot.data ?? {
        'water': 0,
        'food': 0,
        'poop': 0,
        'vomit': 0,
      };

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '오늘의 기록',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCountItem(colorScheme, '물', counts['water']!, Icons.water_drop),
                _buildCountItem(colorScheme, '사료', counts['food']!, Icons.restaurant),
                _buildCountItem(colorScheme, '대변', counts['poop']!, Icons.recycling),
                _buildCountItem(colorScheme, '구토', counts['vomit']!, Icons.sick),
              ],
            ),
          ],
        ),
      );
    },
  );
}

Stream<int> _getCollectionCount(String petId, String date, String collectionName) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('pets')
      .doc(petId)
      .collection('tracking')
      .doc(date)
      .collection(collectionName)
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
}

Widget _buildCountItem(ColorScheme colorScheme, String label, int count, IconData icon) {
  return Column(
    children: [
      Icon(icon, color: colorScheme.primary, size: 24),
      const SizedBox(height: 8),
      Text(
        label,
        style: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      const SizedBox(height: 4),
      Text(
        count.toString(),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
    ],
  );
}

  Widget _buildCareSchedule(ColorScheme colorScheme) {
  return StreamBuilder<List<ScheduleInfo>>(
    stream: _getUpcomingSchedulesStream(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }
      final schedules = snapshot.data ?? [];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '다가오는 일정',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onBackground),
            ),
          ),
          if (schedules.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                '없음',
                style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
              ),
            )
          else
            ...schedules.map((schedule) => _buildScheduleCard(colorScheme, schedule)).toList(),
        ],
      );
    },
  );
}

  Widget _buildScheduleCard(ColorScheme colorScheme, ScheduleInfo schedule) {
  final daysLeft = _calculateDaysLeft(schedule.date);
  String dDayText = daysLeft == 0 ? 'D-day' : 'D-$daysLeft';

  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: schedule.type.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                ),
                Text(
                  '${schedule.type.name} - ${DateFormat('yyyy/MM/dd').format(schedule.date)}',
                  style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                ),
                if (schedule.description != null && schedule.description!.isNotEmpty)
                  Text(
                    schedule.description!,
                    style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                dDayText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: daysLeft == 0 ? Colors.red : colorScheme.primary,
                ),
              ),
              Text(
                schedule.owner.name,
                style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
  Widget _buildBottomButton(
      String label, IconData icon, ColorScheme colorScheme) {
    return Column(
      children: [
        Icon(icon, color: colorScheme.primary),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: colorScheme.primary)),
      ],
    );
  }

  String _calculateAge(String birthDate) {
    final birth = DateTime.parse(birthDate);
    final now = DateTime.now();
    int age = now.year - birth.year;
    if (now.month < birth.month ||
        (now.month == birth.month && now.day < birth.day)) {
      age--;
    }
    return '$age살';
  }

  Stream<List<ScheduleInfo>> _getUpcomingSchedulesStream() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('pets')
      .snapshots()
      .switchMap((petsSnapshot) {
    List<Stream<List<ScheduleInfo>>> petStreams = petsSnapshot.docs.map((petDoc) {
      final petId = petDoc.id;
      final petName = petDoc['petName'];

      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('pets')
          .doc(petId)
          .collection('appointments')
          .where('date', isGreaterThanOrEqualTo: today.toIso8601String())
          .orderBy('date')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return ScheduleInfo(
            id: doc.id,
            owner: Pet(id: petId, name: petName),
            type: ScheduleTypeInfo(data['type'], Color(data['typeColor'] ?? 0xFF000000)),
            title: data['title'] as String,
            date: DateTime.parse(data['date'] as String),
            isAllDay: data['isAllDay'] as bool,
            startTime: data['startTime'] != null 
                ? TimeOfDay.fromDateTime(DateTime.parse(data['startTime'] as String))
                : null,
            endTime: data['endTime'] != null 
                ? TimeOfDay.fromDateTime(DateTime.parse(data['endTime'] as String))
                : null,
            description: data['description'] as String?,
          );
        }).toList();
      });
    }).toList();

    return Rx.combineLatest(petStreams, (List<List<ScheduleInfo>> listOfLists) {
      List<ScheduleInfo> allSchedules = listOfLists.expand((list) => list).toList();
      allSchedules.sort((a, b) => a.date.compareTo(b.date));
      return allSchedules.take(2).toList();
    });
  });
}

  int _calculateDaysLeft(DateTime scheduleDate) {
  final now = DateTime.now();
  final difference = scheduleDate.difference(now);
  return difference.inDays + 1;
}
}
