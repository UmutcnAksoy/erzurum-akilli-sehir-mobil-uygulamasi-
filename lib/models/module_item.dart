// lib/models/module_item.dart (NİHAİ KOD)

import 'package:flutter/material.dart';

class ModuleItem {
  final String title;
  final IconData icon;
  final Color color;
  final String routeName; 

  const ModuleItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.routeName,
  });
}

// Siyah-Beyaz temaya uygun Gri ikonlar
const List<ModuleItem> allModules = [
  ModuleItem(
    title: "Kültür & Tarihi Mekan", 
    icon: Icons.museum, 
    color: Colors.grey, // Siyah/Beyaz Tema
    routeName: "/culture",
  ),
  ModuleItem(
    title: "Kafe & Restoran", 
    icon: Icons.restaurant, 
    color: Colors.grey, 
    routeName: "/food",
  ),
  ModuleItem(
    title: "Üniversiteler", 
    icon: Icons.school, 
    color: Colors.grey, 
    routeName: "/universities",
  ),
  ModuleItem(
    title: "Eczane & Hastane", 
    icon: Icons.medical_services, 
    color: Colors.grey, 
    routeName: "/health",
  ),
  ModuleItem(
    title: "Otel & Apart", 
    icon: Icons.hotel, 
    color: Colors.grey, 
    routeName: "/lodging",
  ),
  ModuleItem(
    title: "Toplu Taşıma", 
    icon: Icons.directions_bus, 
    color: Colors.grey, 
    routeName: "/transport",
  ),
];