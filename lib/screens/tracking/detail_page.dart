import 'package:flutter/material.dart';
import 'package:mncare/screens/tracking/add_%20poop_page.dart';
import 'package:mncare/screens/tracking/add_food_page.dart';
import 'package:mncare/screens/tracking/add_vomit_page.dart';
import 'package:mncare/screens/tracking/add_water_page.dart';
import 'package:mncare/screens/tracking/set_intake_goals.dart';

import 'tracking_info.dart';

class DetailPage extends StatelessWidget {
  final String title;

  const DetailPage({super.key, required this.title});

  double _getContainerHeight(String title) {
    if (title == '물' || title == '사료') {
      return 494;
    } else {
      return 684;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
          child: Column(
        children: [
          if (title == '물' || title == '사료') // 물이나 사료인 경우에만 띄우기
            SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '20/200', 
                    // 데이터 받아서 띄우게 수정
                    //
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
                  ),
                  if (title == '물')
                    const Text(
                      'ml',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
                    ),
                  if (title == '사료')
                    const Text(
                      'g',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
                    ),
                ],
              ),
            ),
          if (title == '물' || title == '사료') // 물이나 사료인 경우에만 섭취루틴 띄우기
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
                                  builder: (context) =>
                                      SetIntakeGoals(title: title)),
                            );
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
                                const Text(
                                  '200', // 데이터 가져와서 띄우게 수정
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (title == '물')
                                  const Text(
                                    'ml',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                if (title == '사료')
                                  const Text(
                                    'g',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const Row(
                          children: [
                            Text(
                              '목표 횟수',
                              style: TextStyle(
                                color: Color.fromARGB(255, 80, 80, 80),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              '3회', // 데이터 가져와서 띄우게 수정
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          if (title == '물' || title == '사료') // 물이나 사료인 경우에만 여백 띄우기
            Container(
              height: 10,
              color: const Color.fromARGB(255, 240, 240, 240),
            ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: GestureDetector(
              onTap: () {
                if (title == '물') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddWaterPage()),
                  );
                }
                if (title == '사료') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddFoodPage()),
                  );
                }
                if (title == '대변') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddPoopPage()),
                  );
                }
                if (title == '구토') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddVomitPage()),
                  );
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
              height: _getContainerHeight(title),
              padding: const EdgeInsets.fromLTRB(25, 12.5, 25, 12.5),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 240, 240, 240),
                borderRadius: BorderRadius.circular(25),
              ),
              child: trackingExList.isEmpty // 데이터 가져와서 검사하게 수정
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
                      itemCount: trackingExList.length, // 데이터 가져오게 수정
                      itemBuilder: (context, index) {
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
                                    Text(
                                      trackingExList[index], // 데이터 가져와서 띄우게 수정
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    const Text(
                                      '  ·  ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Text(
                                      '20', // 데이터 가져와서 띄우게 수정
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    if (title == '물')
                                      const Text(
                                        'ml',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    if (title == '사료')
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
                                      onPressed: () {}, // 기록 삭제 로직으로 수정
                                      icon: const Icon(Icons.delete),
                                      color: Colors.grey,
                                    ),
                                    IconButton(
                                      onPressed:
                                          () {}, // 기록 수정 로직으로 수정 이거는 기록 추가 화면 띄우는 대신 데이터를 여기서 가지고 있는 데이터로 넣어주면 될듯
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
