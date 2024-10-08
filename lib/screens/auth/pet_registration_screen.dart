import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mncare/screens/main_screen.dart';
import 'package:mncare/utilities/dailyFoodLogic.dart' as dailyFoodLogic;
import 'package:mncare/utilities/dailyWaterLogic.dart';

class PetRegistrationScreen extends StatefulWidget {
  final bool showSkipButton;

  const PetRegistrationScreen({super.key, this.showSkipButton = true});

  @override
  _PetRegistrationScreenState createState() => _PetRegistrationScreenState();
}

class _PetRegistrationScreenState extends State<PetRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _gender;
  bool _isNeutered = true;
  String? _petType;
  String? _breed;
  final _weightController = TextEditingController();
  final _birthController = TextEditingController();
  final _otherController = TextEditingController();

  final List<String> _dogBreeds = [
    '골든 리트리버',
    '라브라도 리트리버',
    '비글',
    '불독',
    '시베리안 허스키',
    '요크셔 테리어',
    '저먼 셰퍼드',
    '치와와',
    '푸들',
    '프렌치 불독',
  ];
  final List<String> _catBreeds = [
    '노르웨이 숲',
    '러시안 블루',
    '메인쿤',
    '뱅갈',
    '브리티시 숏헤어',
    '샴',
    '스코티시 폴드',
    '아메리칸 숏헤어',
    '코리안 숏헤어',
    '페르시안',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          if (widget.showSkipButton)
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                );
              },
              child: const Text('건너뛰기', style: TextStyle(color: Colors.black)),
            ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '함께하고 있는\n반려동물 정보를 알려주세요',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Text('이름'),
                  const SizedBox(height: 10),
                  _buildTextField(_nameController, '이름'),
                  const SizedBox(height: 16),
                  const Text('반려동물 종류'),
                  const SizedBox(height: 10),
                  _buildBreedSelection(),
                  const SizedBox(height: 16),
                  const Text('성별'),
                  const SizedBox(height: 10),
                  _buildGenderSelection(),
                  const SizedBox(height: 16),
                  const Text('중성화 유무'),
                  const SizedBox(height: 10),
                  _buildNeuterSelection(),
                  const SizedBox(height: 16),
                  const Text('체중'),
                  const SizedBox(height: 10),
                  _buildTextField(_weightController, '체중', suffix: 'kg'),
                  const SizedBox(height: 16),
                  const Text('생년월일'),
                  const SizedBox(height: 10),
                  _buildBirthdayField(),
                  const SizedBox(height: 16),
                  const Text('특이사항'),
                  const SizedBox(height: 10),
                  _buildTextField(_otherController, '갖고 있는 질환이나 알러지원을 적어주세요',
                      isRequired: false),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 235, 91, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      minimumSize: const Size(double.infinity, 55),
                    ),
                    child: const Text(
                      '저장',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {String? suffix, bool isRequired = true}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
      validator: isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return '$label을(를) 입력해주세요';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildGenderSelection() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => setState(() => _gender = '남아'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _gender == '남아'
                  ? const Color.fromARGB(255, 255, 178, 0)
                  : Colors.white,
              foregroundColor: _gender == '남아' ? Colors.white : Colors.black,
              fixedSize: const Size(100, 50),
              side: _gender != '남아'
                  ? const BorderSide(
                      width: 1, color: Color.fromARGB(79, 158, 158, 158))
                  : BorderSide.none,
            ),
            child: const Text(
              '남아',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => setState(() => _gender = '여아'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _gender == '여아'
                  ? const Color.fromARGB(255, 255, 178, 0)
                  : Colors.white,
              foregroundColor: _gender == '여아' ? Colors.white : Colors.black,
              fixedSize: const Size(100, 50),
              side: _gender != '여아'
                  ? const BorderSide(
                      width: 1, color: Color.fromARGB(79, 158, 158, 158))
                  : BorderSide.none,
            ),
            child: const Text(
              '여아',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNeuterSelection() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => setState(() => _isNeutered = true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isNeutered
                  ? const Color.fromARGB(255, 255, 178, 0)
                  : Colors.white,
              foregroundColor: _isNeutered ? Colors.white : Colors.black,
              fixedSize: const Size(100, 50),
              side: !_isNeutered
                  ? const BorderSide(
                      width: 1, color: Color.fromARGB(127, 158, 158, 158))
                  : BorderSide.none,
            ),
            child: const Text(
              '했어요',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => setState(() => _isNeutered = false),
            style: ElevatedButton.styleFrom(
              backgroundColor: !_isNeutered
                  ? const Color.fromARGB(255, 255, 178, 0)
                  : Colors.white,
              foregroundColor: !_isNeutered ? Colors.white : Colors.black,
              fixedSize: const Size(100, 50),
              side: _isNeutered
                  ? const BorderSide(
                      width: 1, color: Color.fromARGB(127, 158, 158, 158))
                  : BorderSide.none,
            ),
            child: const Text(
              '안 했어요',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBreedSelection() {
    return GestureDetector(
      onTap: () => _showBreedSelectionDialog(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _breed != null ? '$_petType - $_breed' : '반려동물 종류를 선택해 주세요',
              style: const TextStyle(
                  fontSize: 16, color: Color.fromARGB(255, 83, 83, 83)),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  void _showBreedSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(
          child: Text(
            '반려동물 종류 선택',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.white,
        content: SizedBox(
          width: double.maxFinite,
          child: DefaultTabController(
            length: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TabBar(
                  labelColor: Color.fromARGB(255, 235, 91, 0),
                  unselectedLabelColor: Colors.grey,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  unselectedLabelStyle: TextStyle(fontStyle: FontStyle.normal),
                  indicatorColor: Color.fromARGB(255, 235, 91, 0),
                  tabs: [
                    Tab(text: '강아지'),
                    Tab(text: '고양이'),
                  ],
                ),
                SizedBox(
                  height: 300,
                  child: TabBarView(
                    children: [
                      _buildBreedList('강아지', _dogBreeds),
                      _buildBreedList('고양이', _catBreeds),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreedList(String petType, List<String> breeds) {
    return ListView.builder(
      itemCount: breeds.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(breeds[index]),
          onTap: () {
            setState(() {
              _petType = petType;
              _breed = breeds[index];
            });
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Widget _buildBirthdayField() {
    return TextFormField(
      controller: _birthController,
      decoration: const InputDecoration(
        labelText: '생년월일',
        hintText: 'YYYYMMDD',
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
      keyboardType: TextInputType.datetime,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        LengthLimitingTextInputFormatter(8),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '생년월일을 입력해주세요';
        }
        // 입력 당일 포함 이전의 날짜가 아니면 입력이 안되게 하는 로직..
        return null;
      },
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? currentUser = FirebaseAuth.instance.currentUser;

        /**트래킹 관련 DB저장 로직 */
        int defaultFoodKcal = 3500;// 예시로 3500 kcal/kg 사용 임시 값인거임.
        double dailyFoodAmount = dailyFoodLogic.calculateDailyFood(
          petType: _petType!,
          age: dailyFoodLogic.calculateAgeInMonths(_birthController.text),
          weight: double.parse(_weightController.text),
          defaultFoodKcal: defaultFoodKcal, 
          isNeutered: _isNeutered,
        );
        int defaultFoodCount = 3;
        double dailyWaterAmount = calculateDailyWater(
            petType: _petType!,
            age: calculateAgeInMonths(_birthController.text),
            weight: double.parse(_weightController.text),
            isNeutered: _isNeutered,
          );
        int defaultWaterCount = 2;


        if (currentUser != null) {
          DocumentReference petDocRef = await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .collection('pets')
              .add({
            'petName': _nameController.text,
            'petType': _petType,
            'petBreed': _breed,
            'petGender': _gender,
            'isNeutered': _isNeutered,
            'petWeight': double.parse(_weightController.text),
            'petBirthDate': _birthController.text,
            'etc':
                _otherController.text.isNotEmpty ? _otherController.text : null,
          });

          String petId = petDocRef.id; // 반려동물의 ID 인데 사용함?

          /*좀이따 standard DB 만드는 로직  */
          // petDocRef 하위에 standard 문서를 만들고, 거기에 defaultFoodGoal 저장
          await petDocRef.collection('standard').doc('document').set({
            'defaultFoodGoal': dailyFoodAmount,
            'defaultFoodCount': defaultFoodCount,
            'defaultWaterGoal': dailyWaterAmount,
            'defaultWaterCount': defaultWaterCount,
            'defaultFoodKcal': defaultFoodKcal,
          });
          //의도한 구조가 아니긴함. standard 하위에 바로 defaultFoodGoal이 속성으로 저장되었으면 좋겠음.

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('반려동물 정보가 성공적으로 저장되었습니다!')),
          );

          // 메인 화면으로 이동
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          throw Exception('로그인된 사용자가 없습니다');
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('반려동물 정보 저장에 실패했습니다: $error')),
        );
      }
    }
  }
}
