import 'package:flutter/material.dart';
import 'package:mncare/screens/pet_doctor/pet_doctor_screen.dart';

class PetDoctorList extends StatefulWidget {
  const PetDoctorList({super.key});

  @override
  State<PetDoctorList> createState() => _PetDoctorListState();
}

class _PetDoctorListState extends State<PetDoctorList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => const PetDoctorScreen(),
              ),
            );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}