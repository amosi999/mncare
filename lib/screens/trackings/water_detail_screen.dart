import 'package:flutter/material.dart';

class WaterDetailScreen extends StatelessWidget {
  final String label;
  final int value;

  WaterDetailScreen({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${label} 상세보기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${label}: ${value}', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
