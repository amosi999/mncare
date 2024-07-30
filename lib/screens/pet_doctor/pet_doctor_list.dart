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
}

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
      petName: '', // This will be set later
    );
  }
}

class PetDoctorList extends StatefulWidget {
  const PetDoctorList({super.key});

  @override
  State<PetDoctorList> createState() => _PetDoctorListState();
}

class _PetDoctorListState extends State<PetDoctorList> {
  List<PetImage> _petImages = [];
  List<Pet> _pets = [];
  Pet? _selectedPet;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataWithRefresh();
    });
  }

  

  Future<void> _loadDataWithRefresh() async {
    // 새로고침 인디케이터를 표시합니다.
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    // 데이터를 새로 로드합니다.
    await _loadData();

    // 새로고침 인디케이터를 숨깁니다.
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    await Future.wait([_loadPets(), _loadPetImages()]);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadPets() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('pets')
          .get();

      setState(() {
        _pets = querySnapshot.docs
            .map((doc) => Pet(id: doc.id, name: doc['petName'] ?? 'Unknown Pet'))
            .toList();
        if (_pets.isNotEmpty) {
          _selectedPet = null;
        }
      });
    }
  }

  Future<void> _loadPetImages() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _petImages.clear();
      for (var pet in _pets) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('pets')
            .doc(pet.id)
            .collection('petDoctor')
            .orderBy('createdDate', descending: true)
            .get();

        final petImages = querySnapshot.docs
            .map((doc) => PetImage.fromFirestore(doc, pet.id))
            .toList();

        // Fetch pet name for each image
        for (var image in petImages) {
          final petDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('pets')
              .doc(image.petId)
              .get();
          image.petName = petDoc['petName'] ?? 'Unknown Pet';
        }

        _petImages.addAll(petImages);
      }
      _petImages.sort((a, b) => b.createdDate.compareTo(a.createdDate));  //전체보기에서 최신순으로 정렬

      setState(() {});
    }
  }

  Future<void> _deletePetImage(PetImage petImage) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Delete from Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('pets')
            .doc(petImage.petId)
            .collection('petDoctor')
            .doc(petImage.id)
            .delete();

        // Delete from Firebase Storage
        final storageRef = FirebaseStorage.instance.refFromURL(petImage.imageUrl);
        await storageRef.delete();

        setState(() {
          _petImages.remove(petImage);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지가 Firestore와 Storage에서 성공적으로 삭제되었습니다')),
        );
      }
    } catch (e) {
      print('이미지 삭제 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 삭제 실패: $e')),
      );
    }
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
            return PetImageDetailView(petImage: petImage, scrollController: controller);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<PetImage> filteredImages = _selectedPet == null
        ? _petImages
        : _petImages.where((image) => image.petId == _selectedPet!.id).toList();

    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
          onRefresh: _loadDataWithRefresh,
          child: Column(
              children: [
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
                      ..._pets.map((Pet pet) {
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
                Expanded(
                  
                    child: ToggleList(
                      divider: const SizedBox(height: 8),
                      toggleAnimationDuration: const Duration(milliseconds: 300),
                      scrollPosition: AutoScrollPosition.begin,
                      children: filteredImages.map((petImage) {
                        return ToggleListItem(
                          title: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(petImage.imageUrl),
                                  radius: 25,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat('yyyy-MM-dd HH:mm').format(petImage.createdDate),
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        petImage.petName,
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          content: PetImageItem(petImage, onDelete: () => _deletePetImage(petImage), onView: () => _showDetailView(petImage)),
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
                ),
            ),
          
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => const PetDoctorScreen(),
            ),
          );
          _loadData();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[700],
      ),
    );
  }
}

class PetImageItem extends StatelessWidget {
  const PetImageItem(this.petImage, {super.key, required this.onDelete, required this.onView});

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
                label:const Text('상세 보기'),
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

  const PetImageDetailView({Key? key, required this.petImage, required this.scrollController})
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