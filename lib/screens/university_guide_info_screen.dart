import 'package:flutter/material.dart';

class UniversityGuideInfoScreen extends StatelessWidget {
  static const routeName = '/university-guide-info';
  final String universityId;

  const UniversityGuideInfoScreen({Key? key, required this.universityId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rehber Bilgisi')),
      body: Center(child: Text('Rehber Detayları (ID: $universityId)')),
    );
  }
}