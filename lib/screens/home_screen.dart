/*
=============================================================================

HOME SCREEN

This teaches navigation.

Navigator.push()

moves to another screen.

=============================================================================
*/

import 'package:flutter/material.dart';

import '../widgets/lesson_card.dart';

import 'widgets_screen.dart';
import 'layouts_screen.dart';
import 'state_screen.dart';
import 'api_screen.dart';
import 'memory_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Learning"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            LessonCard(
              title: "Widgets",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WidgetsScreen(),
                  ),
                );
              },
            ),
            LessonCard(
              title: "Layouts",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LayoutsScreen(),
                  ),
                );
              },
            ),
            LessonCard(
              title: "State",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StateScreen(),
                  ),
                );
              },
            ),
            LessonCard(
              title: "API",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ApiScreen(),
                  ),
                );
              },
            ),
            LessonCard(
              title: "Memory",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MemoryScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}