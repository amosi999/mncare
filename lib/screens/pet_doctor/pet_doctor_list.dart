import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mncare/screens/pet_doctor/pet_doctor_screen.dart';
import 'package:intl/intl.dart';
import 'package:toggle_list/toggle_list.dart';

class Pet {
  final String id;
  final String name;

  Pet({required this.id, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pet && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class PetImage {
  final String id;
  final String imageUrl;
  final DateTime createdDate;
  final String petId;
  String petName;
  Map<String, dynamic>? prediction;

  PetImage({
    required this.id,
    required this.imageUrl,
    required this.createdDate,
    required this.petId,
    required this.petName,
    this.prediction,
  });

  factory PetImage.fromFirestore(DocumentSnapshot doc, String petId) {
    Map data = doc.data() as Map<String, dynamic>;
    return PetImage(
      id: doc.id,
      imageUrl: data['img_url'] ?? '',
      createdDate: (data['createdDate'] as Timestamp).toDate(),
      petId: petId,
      petName: '', // 나중에 설정됨
      prediction: data['prediction'],
    );
  }
}

class PetDoctorList extends StatefulWidget {
  const PetDoctorList({Key? key}) : super(key: key);

  @override
  State<PetDoctorList> createState() => _PetDoctorListState();
}

class _PetDoctorListState extends State<PetDoctorList> {
  Pet? _selectedPet;

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
          const SnackBar(content: Text('이미지가 성공적으로 삭제되었습니다')),
        );

        // 상태 업데이트를 위해 setState 호출
        setState(() {});
      }
    } catch (e) {
      print('이미지 삭제 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 삭제 실패: $e')),
      );
    }
  }

  void _refreshData() {
    setState(() {});
  }

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
              petImage: petImage,
              scrollController: controller,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: StreamBuilder<List<Pet>>(
        stream: _getPetsStream(),
        builder: (context, petsSnapshot) {
          if (petsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
                return const Center(child: CircularProgressIndicator());
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: DropdownButtonFormField<Pet?>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
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
                          return DropdownMenuItem<Pet?>(
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
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      Text(
                                        petImage.petName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          content: PetImageItem(
                            petImage: petImage,
                            onDelete: () => _deletePetImage(petImage),
                            onView: () => _showDetailView(petImage),
                          ),
                          headerDecoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
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
                            color: Theme.of(context).colorScheme.surfaceVariant,
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
      floatingActionButton: SizedBox(
        width: 48,
        height: 48,
        child: FloatingActionButton(
          heroTag: 'addPost1',
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
          backgroundColor: const Color.fromARGB(255, 235, 91, 0),
          shape: const CircleBorder(),
          elevation: 1,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class PetImageItem extends StatelessWidget {
  final PetImage petImage;
  final VoidCallback onDelete;
  final VoidCallback onView;

  const PetImageItem({
    Key? key,
    required this.petImage,
    required this.onDelete,
    required this.onView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
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
                  color: Theme.of(context).colorScheme.surfaceVariant,
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

class PetImageDetailView extends StatelessWidget {
  final PetImage petImage;
  final ScrollController scrollController;

  const PetImageDetailView({
    Key? key,
    required this.petImage,
    required this.scrollController,
  }) : super(key: key);

  String _getSymptomName(int classNumber) {
    switch (classNumber) {
      case 1:
        return '구진 플라크';
      case 2:
        return '비듬 각질 상피성잔고리';
      case 3:
        return '태선화 과다 색소 침착';
      case 4:
        return '농포 여드름';
      case 5:
        return '미란 궤양';
      case 6:
        return '결절 종괴';
      case 7:
        return '무증상';
      default:
        return '알 수 없음';
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            petImage.petName,
            style: Theme.of(context).textTheme.headlineSmall,
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
                  color: Theme.of(context).colorScheme.surfaceVariant,
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
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          if (petImage.prediction != null) ...[
            Text(
              '예측 결과:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '증상: ${_getSymptomName(petImage.prediction!['predicted_class'])}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              '신뢰도: ${(petImage.prediction!['confidence'] * 100).toStringAsFixed(2)}%',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }
}
