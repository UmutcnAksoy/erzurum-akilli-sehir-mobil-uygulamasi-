// lib/screens/modules_screen.dart

import 'package:flutter/material.dart';

class ModulesScreen extends StatelessWidget {
  // Yapıcı (constructor) tanımı. Hata bu tanım eksik olduğu için oluştu.
  const ModulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tüm Modüller ve Hizmetler'),
        backgroundColor: Colors.blueGrey.shade200,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.apps, size: 80, color: Colors.blueGrey),
              SizedBox(height: 20),
              Text(
                "Kültür, Yemek, Eczane ve diğer modüllerin listesi burada yer alacak.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}