/*
=============================================================================

ENTRY POINT

Flutter starts here.

Flow:

main()
 ↓
runApp()
 ↓
LearningApp()
 ↓
MaterialApp()
 ↓
HomeScreen()

=============================================================================
*/

import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const LearningApp());
}

class LearningApp extends StatelessWidget {
  const LearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Learning',
      home: const HomeScreen(),
    );
  }
}
