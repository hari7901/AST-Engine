// main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'test_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Initial user data can be empty or have default values
  Map<String, dynamic> userData = {
    "age": 35,
    "department": "Sales",
    "salary": 60000,
    "experience": 3,
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rule Engine App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TestScreen(
        userData: userData,
        onUserDataChanged: (updatedData) {
          setState(() {
            userData = Map<String, dynamic>.from(updatedData);
          });
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
