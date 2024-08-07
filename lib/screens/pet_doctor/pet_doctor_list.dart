import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mncare/screens/pet_doctor/pet_doctor_screen.dart';
import 'package:intl/intl.dart';
import 'package:toggle_list/toggle_list.dart';

// Pet 클래스 정의 (변경 없음)
class Pet {
  final String id;
  final String name;

  Pet({required this.id, required this.name});
}

// PetImage 클래스 정의 (변경 없음)
class PetImage {
  final String id;
  final String imageUrl;
  final DateTime createdDate;
  final String petId;
  String petName;

  PetImage({
    required this.id,
    required this.imageUrl,
    required this.createdDate,
    required this.petId,
    required this.petName,
  });

  factory PetImage.fromFirestore(DocumentSnapshot doc, String petId) {
    Map data = doc.data() as Map<String, dynamic>;
    return PetImage(
      id: doc.id,
      imageUrl: data['img_url'] ?? '',
      createdDate: (data['createdDate'] as Timestamp).toDate(),
      petId: petId,
      petName: '', // 나중에 설정됨
    );
  }
}

class PetDoctorList extends StatefulWidget {
  const PetDoctorList({super.key});

  @override
  State<PetDoctorList> createState() => _PetDoctorListState();
}

class _PetDoctorListState extends State<PetDoctorList> {
  Pet? _selectedPet;

  // 반려동물 목록을 가져오는 Stream
  Stream<List<Pet>> _getPetsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('pets')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map(
                (doc) => Pet(id: doc.id, name: doc['petName'] ?? 'Unknown Pet'))
            .toList();
      });
    }
    return Stream.value([]);
  }

  // 모든 반려동물의 이미지를 가져오는 Stream
  Stream<List<PetImage>> _getPetImagesStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('pets')
          .snapshots()
          .asyncMap((petsSnapshot) async {
        List<PetImage> allPetImages = [];
        for (var petDoc in petsSnapshot.docs) {
          final petId = petDoc.id;
          final petName = petDoc['petName'] ?? 'Unknown Pet';
          final imagesSnapshot = await petDoc.reference
              .collection('petDoctor')
              .orderBy('createdDate', descending: true)
              .get();

          final petImages = imagesSnapshot.docs.map((imageDoc) {
            final petImage = PetImage.fromFirestore(imageDoc, petId);
            petImage.petName = petName;
            return petImage;
          }).toList();

          allPetImages.addAll(petImages);
        }
        allPetImages.sort((a, b) => b.createdDate.compareTo(a.createdDate));
        return allPetImages;
      });
    }
    return Stream.value([]);
  }

  // 이미지 삭제 함수
  Future<void> _deletePetImage(PetImage petImage) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Firestore에서 삭제
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('pets')
            .doc(petImage.petId)
            .collection('petDoctor')
            .doc(petImage.id)
            .delete();

        // Firebase Storage에서 삭제
        final storageRef =
            FirebaseStorage.instance.refFromURL(petImage.imageUrl);
        await storageRef.delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('이미지가 Firestore와 Storage에서 성공적으로 삭제되었습니다')),
        );
      }
    } catch (e) {
      print('이미지 삭제 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 삭제 실패: $e')),
      );
    }
  }

  void _refreshData() {
    setState(() {
      // StreamBuilder를 사용하고 있으므로, setState만 호출해도 
      // 스트림이 새로운 데이터를 가져오게 됩니다.
    });
  }

  // 상세 보기 모달 표시 함수
  void _showDetailView(PetImage petImage) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return PetImageDetailView(
                petImage: petImage, scrollController: controller);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 240, 240),
      body: StreamBuilder<List<Pet>>(
        stream: _getPetsStream(),
        builder: (context, petsSnapshot) {
          if (petsSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (petsSnapshot.hasError) {
            return Center(child: Text('오류: ${petsSnapshot.error}'));
          }

          final pets = petsSnapshot.data ?? [];

          return StreamBuilder<List<PetImage>>(
            stream: _getPetImagesStream(),
            builder: (context, petImagesSnapshot) {
              if (petImagesSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (petImagesSnapshot.hasError) {
                return Center(child: Text('오류: ${petImagesSnapshot.error}'));
              }

              final allPetImages = petImagesSnapshot.data ?? [];
              final filteredImages = _selectedPet == null
                  ? allPetImages
                  : allPetImages
                      .where((image) => image.petId == _selectedPet!.id)
                      .toList();

              return Column(
                children: [
                  // 반려동물 선택 드롭다운
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: DropdownButtonFormField<Pet?>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      value: _selectedPet,
                      items: [
                        const DropdownMenuItem<Pet?>(
                          value: null,
                          child: Text('전체 보기'),
                        ),
                        ...pets.map((Pet pet) {
                          return DropdownMenuItem<Pet>(
                            value: pet,
                            child: Text(pet.name),
                          );
                        }).toList(),
                      ],
                      onChanged: (Pet? newValue) {
                        setState(() {
                          _selectedPet = newValue;
                        });
                      },
                    ),
                  ),
                  // 이미지 목록
                  Expanded(
                    child: ToggleList(
                      divider: const SizedBox(height: 8),
                      toggleAnimationDuration:
                          const Duration(milliseconds: 300),
                      scrollPosition: AutoScrollPosition.begin,
                      children: filteredImages.map((petImage) {
                        return ToggleListItem(
                          title: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(petImage.imageUrl),
                                  radius: 25,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat('yyyy-MM-dd HH:mm')
                                            .format(petImage.createdDate),
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        petImage.petName,
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          content: PetImageItem(petImage,
                              onDelete: () => _deletePetImage(petImage),
                              onView: () => _showDetailView(petImage)),
                          headerDecoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          expandedHeaderDecoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => PetDoctorScreen(
                onImageUploaded: _refreshData,
              ),
              
            ),
          );
          _refreshData();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[700],
      ),
    );
  }
}

// PetImageItem 클래스 (변경 없음)
class PetImageItem extends StatelessWidget {
  const PetImageItem(this.petImage,
      {super.key, required this.onDelete, required this.onView});

  final PetImage petImage;
  final VoidCallback onDelete;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              petImage.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: onView,
                icon: const Icon(Icons.visibility),
                label: const Text('상세 보기'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete),
                label: const Text('삭제'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// PetImageDetailView 클래스 (변경 없음)
class PetImageDetailView extends StatelessWidget {
  final PetImage petImage;
  final ScrollController scrollController;

  const PetImageDetailView(
      {Key? key, required this.petImage, required this.scrollController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            petImage.petName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              petImage.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 300,
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '날짜: ${formatter.format(petImage.createdDate)}',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('닫기'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
