import 'package:flutter/material.dart';

class UniversityPlacesScreen extends StatelessWidget {
  static const routeName = '/university-places';
  final String universityId;

  const UniversityPlacesScreen({Key? key, required this.universityId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Üniversite Mekanları')),
      body: Center(child: Text('Mekan Listesi (ID: $universityId)')),
    );
  }
}
