import 'package:flutter/material.dart';
import 'package:mncare/screens/tracking/tracking_screen_controller.dart';

import 'calendar_widget.dart';
import 'tracking_grid.dart';

class TrackingScreen extends StatefulWidget {
  final TrackingScreenController controller;

  const TrackingScreen({super.key, required this.controller});

  @override
  _TrackingPageState createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 240, 240),
      body: Column(
        children: [
          CalendarWidget(
            selectedDate: widget.controller.selectedDate,
            onDateChanged: (date) {
              setState(() {
                widget.controller.updateSelectedDate(date);
              });
            },
          ),
          const TrackingGrid(),
        ],
      ),
    );
  }
}
