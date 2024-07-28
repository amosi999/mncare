import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mncare/screens/pet_doctor/pet_doctor_screen.dart';
import 'package:intl/intl.dart'; 

class Pet {
  final String id;
  final String name;

  Pet({required this.id, required this.name});
}

class PetImage {
  final String id;
  final String imageUrl;
  final DateTime createdDate;

  PetImage({
    required this.id,
    required this.imageUrl,
    required this.createdDate,
  });

  factory PetImage.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return PetImage(
      id: doc.id,
      imageUrl: data['img_url'] ?? '',
      createdDate: (data['createdDate'] as Timestamp).toDate(),
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
    _loadData();
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

        _petImages.addAll(querySnapshot.docs
            .map((doc) => PetImage.fromFirestore(doc))
            .toList());
      }
      setState(() {});
    }
  }

  Future<void> _deletePetImage(PetImage petImage) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        for (var pet in _pets) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('pets')
              .doc(pet.id)
              .collection('petDoctor')
              .doc(petImage.id)
              .delete();
        }

        setState(() {
          _petImages.remove(petImage);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image deleted successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete image: $e')),
      );
    }
  }

  void _showDetailView(PetImage petImage) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return PetImageDetailView(petImage: petImage);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<PetImage> filteredImages = _selectedPet == null
        ? _petImages
        : _petImages.where((image) => image.id.startsWith(_selectedPet!.id)).toList();

    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<Pet>(
                    value: _selectedPet,
                    items: [
                      DropdownMenuItem<Pet>(
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
                    isExpanded: true,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredImages.length,
                    itemBuilder: (ctx, index) => Dismissible(
                      key: Key(filteredImages[index].id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        _deletePetImage(filteredImages[index]);
                      },
                      child: GestureDetector(
                        onTap: () => _showDetailView(filteredImages[index]),
                        child: PetImageItem(filteredImages[index]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => const PetDoctorScreen(),
            ),
          );
          _loadPetImages();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PetImageItem extends StatelessWidget {
  const PetImageItem(this.petImage, {super.key});

  final PetImage petImage;

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm'); 

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              petImage.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Text('Date: ${formatter.format(petImage.createdDate)}'), 
          ],
        ),
      ),
    );
  }
}

class PetImageDetailView extends StatelessWidget {
  final PetImage petImage;

  const PetImageDetailView({Key? key, required this.petImage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            petImage.imageUrl,
            height: 300,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text('Date: ${formatter.format(petImage.createdDate)}'), 
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}