import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:salon_management_system/screens/add_person_screen.dart';
import 'package:salon_management_system/screens/cash_out_screen.dart';
import 'package:salon_management_system/screens/cashflow_screen.dart';
import 'package:salon_management_system/screens/home_screen.dart';
import 'package:salon_management_system/screens/reporting_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Salon Management System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(), // Navigate to AddPersonScreen
    );
  }
}
