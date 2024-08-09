import 'package:flutter/material.dart';

import 'calendar_widget.dart';
import 'tracking_grid.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  _TrackingPageState createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingScreen> {
  String selectedPet = '머루';
  DateTime selectedDate = DateTime.now();
  Map<String, Map<String, Map<String, double>>> trackingData = {
    '머루': {},
    '다래': {},
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 240, 240),
      body: Column(
        children: [
          CalendarWidget(
            selectedDate: selectedDate,
            onDateChanged: (date) {
              setState(() {
                selectedDate = date;
              });
            },
          ),
          const TrackingGrid(),
        ],
      ),
    );
  }
}
