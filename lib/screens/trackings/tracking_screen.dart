import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:mncare/screens/trackings/food_detail_screen.dart';
import 'package:mncare/screens/trackings/poop_detail_screen.dart';
import 'package:mncare/screens/trackings/vomit_detail_screen.dart';
import 'package:mncare/screens/trackings/water_detail_screen.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  DateTime _selectedDate = DateTime.now();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, int> _trackingData = {
    'poop': 0,
    'food': 0,
    'vomit': 0,
    'water': 0,
  };
  //이거도 필요가 없음.
  Map<String, dynamic> _foodData = {
    'daily_goal_food': 100, // 추후 공식으로 계산함.
    'feeding_times_food': 4, // 4가 기본값.
  };
  String? _selectedPetId; //선택된 동물의 Id
  List<Pet> _pets = []; //동물 선택을 위한 리스트

  @override
  void initState() {
    super.initState();
    _fetchPets(); //Pets 정보 가져오기
  }

  Future<void> _fetchPets() async {
    if (user == null) return; //사용자 확인

    final querySnapshot = await _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('pets')
        .get();

    setState(() {
      _pets = querySnapshot.docs
          .map((doc) => Pet(id: doc.id, name: doc.data()['petName'] as String))
          .toList();
      if (_pets.isNotEmpty) {
        _selectedPetId = _pets.first.id;
        _loadTrackingData(); //트레킹 기록 불러오기
      }
    });
  }

//여기까진 확인.

  Future<void> _loadTrackingData() async {
    if (user == null || _selectedPetId == null) return; //유저와 펫의 존재 여부 확인

    final String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final DocumentSnapshot doc = await _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('pets')
        .doc(_selectedPetId)
        .collection('trackings')
        .doc(formattedDate)
        .get();
    print('선택된 펫 ID: $_selectedPetId'); //log

    //doc이 존재한다. 이미 해당 날짜에 대한 트래킹이 초기화된거임.
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>?;
      print("Document exists: ${doc.data()}");
      //doc이 존재하면 해당 DB에 있는 데이터를 불러온다.
      //그러면
      if (data != null) {
        setState(() {
          _trackingData = {
            'poop': data['poop'] ?? 0,
            'food': data['food'] ?? 0,
            'vomit': data['vomit'] ?? 0,
            'water': data['water'] ?? 0,
          };
          //이거도 필요 없음.
          _foodData = {
            'daily_goal_food': data['daily_goal_food'] ?? 100,
            'feeding_times_food': data['feeding_times_food'] ?? 4,
          };
        });
      }
    }
    //doc존재하지 않으면
    else {
      print("Document does not exist");
      setState(() {
        _trackingData = {
          'poop': 0,
          'food': 0,
          'vomit': 0,
          'water': 0,
        };
        //이거도 필요 없음.
        _foodData = {
          'daily_goal_food': 100,
          'feeding_times_food': 4,
        };
      });
    }
  }

  Future<void> _updateTrackingData(String key, int value) async {
    if (user == null || _selectedPetId == null || !isToday()) return;

    final String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final DocumentReference docRef = _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('pets')
        .doc(_selectedPetId)
        .collection('trackings')
        .doc(formattedDate);

    setState(() {
      _trackingData[key] = value;
    });

    await docRef.set({
      key: value,
      'daily_goal_food': _foodData['daily_goal_food'],
      'feeding_times_food': _foodData['feeding_times_food'],
    }, SetOptions(merge: true));
  }

  bool isToday() {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: now,
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _loadTrackingData();
      });
    }
  }

  String getTranslatedLabel(String label) {
    switch (label) {
      case 'water':
        return '물';
      case 'poop':
        return '대변';
      case 'food':
        return '사료';
      case 'vomit':
        return '구토';
      default:
        return label;
    }
  }

  void _navigateToDetailScreen(String key) {
    Widget detailScreen;
    switch (key) {
      case 'food':
        detailScreen = FoodDetailScreen(
          label: '사료',
          dailyGoal: _foodData['daily_goal_food'],
          feedingTimes: _foodData['feeding_times_food'],
          selectedPetId: _selectedPetId!, // _selectedPetId를 전달
          onSave: (int newGoal, int newTimes) {
            setState(() {
              _foodData['daily_goal_food'] = newGoal;
              _foodData['feeding_times_food'] = newTimes;
              _updateTrackingData(key, _trackingData[key] ?? 0);
            });
          },
        );
        break;
      case 'poop':
        detailScreen = PoopDetailScreen(
          label: '대변',
          value: _trackingData[key] ?? 0,
        );
        break;
      case 'vomit':
        detailScreen = VomitDetailScreen(
          label: '구토',
          value: _trackingData[key] ?? 0,
        );
        break;
      case 'water':
        detailScreen = WaterDetailScreen(
          label: '물',
          value: _trackingData[key] ?? 0,
        );
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => detailScreen),
    );
  }

  Widget _buildTrackingItem(String label, String key) {
    String translatedLabel = getTranslatedLabel(label);
    int currentFood = (_trackingData['food']! *
            (_foodData['daily_goal_food'] / _foodData['feeding_times_food']))
        .toInt();

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(translatedLabel, style: TextStyle(fontSize: 18)),
              ),
              IconButton(
                icon: Icon(Icons.info_outline),
                onPressed: () {
                  _navigateToDetailScreen(key);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete_outline),
                onPressed: () {
                  setState(() {
                    _trackingData[key] = 0;
                  });
                  _updateTrackingData(key, 0);
                },
              ),
            ],
          ),
          if (key == 'food') ...[
            Text(
              '$currentFood / ${_foodData['daily_goal_food']} g',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              '${_trackingData[key]} / ${_foodData['feeding_times_food']} 회',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
          ] else
            Text(_trackingData[key].toString(), style: TextStyle(fontSize: 24)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: !isToday()
                    ? null
                    : () {
                        if (_trackingData[key]! > 0) {
                          _updateTrackingData(key, _trackingData[key]! - 1);
                        }
                      },
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: !isToday()
                    ? null
                    : () {
                        _updateTrackingData(key, _trackingData[key]! + 1);
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    await _fetchPets();
    await _loadTrackingData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(_selectedDate),
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: _presentDatePicker,
                    ),
                  ],
                ),
              ),
              if (_pets.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: DropdownButton<String>(
                      value: _selectedPetId,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedPetId = newValue;
                          _loadTrackingData();
                        });
                      },
                      items: _pets.map<DropdownMenuItem<String>>((Pet pet) {
                        return DropdownMenuItem<String>(
                          value: pet.id,
                          child: Text(pet.name),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _trackingData.length,
                itemBuilder: (context, index) {
                  String key = _trackingData.keys.elementAt(index);
                  return _buildTrackingItem(key, key);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Pet {
  final String id;
  final String name;

  Pet({required this.id, required this.name});
}
