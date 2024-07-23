import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final formatter = DateFormat.yMd();

class InputInfoScreen extends StatefulWidget {
  const InputInfoScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _InputInfoScreenState();
  }
}

class _InputInfoScreenState extends State<InputInfoScreen> {
  final _form = GlobalKey<FormState>();
  int _selectedPetType = 1;
  int _selectedPetGender = 1;
  DateTime? _selectedDate;
  final _petWeightController = TextEditingController();

  var _enteredPetName = '';
  var _enteredSpecies = '';
  var _enteredEtc = '';

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: now,
    );
    setState(() {
      _selectedDate = pickedDate;
    });
  }

  void _submit() {
    final isValid = _form.currentState!.validate();
    
    if (!isValid) {
      return;
    }
    _form.currentState!.save();

  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('반려동물 정보 입력'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<int>(
                      title: const Text('Dog'),
                      value: 1,
                      groupValue: _selectedPetType,
                      onChanged: (int? value) {
                        setState(() {
                          _selectedPetType= value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<int>(
                      title: const Text('Cat'),
                      value: 2,
                      groupValue: _selectedPetType,
                      onChanged: (int? value) {
                        setState(() {
                          _selectedPetType= value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('petname'),
                decoration: const InputDecoration(labelText: 'PetName'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a pet name.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredPetName = value!;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<int>(
                      title: const Text('남'),
                      value: 1,
                      groupValue: _selectedPetGender,
                      onChanged: (int? value) {
                        setState(() {
                          _selectedPetGender = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<int>(
                      title: const Text('여'),
                      value: 2,
                      groupValue: _selectedPetGender,
                      onChanged: (int? value) {
                        setState(() {
                          _selectedPetGender = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              TextFormField(
                key: const ValueKey('petspecies'),
                decoration: const InputDecoration(labelText: 'Species'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter species.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredSpecies = value!;
                },
              ),
              const SizedBox(height: 16),
              Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _petWeightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    suffixText: 'Kg',
                    label: Text('Weight'),
                  ),
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(_selectedDate == null
                        ? 'No date chosen'
                        : formatter.format(_selectedDate!)), // ! = no null
                    IconButton(
                        onPressed: _presentDatePicker,
                        icon: const Icon(Icons.calendar_month)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('petEtc'),
                decoration: const InputDecoration(labelText: 'etc'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter etc.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredEtc = value!;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}