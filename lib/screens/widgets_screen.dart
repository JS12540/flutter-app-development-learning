/*
=============================================================================

WIDGET LESSON

Everything in Flutter is a Widget.

Text
Icon
Button
Card

are all widgets.

=============================================================================
*/

import 'package:flutter/material.dart';

class WidgetsScreen extends StatelessWidget {
  const WidgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Widgets"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Text Widget",
            style: TextStyle(fontSize: 24),
          ),

          const SizedBox(height: 20),

          const Icon(
            Icons.flutter_dash,
            size: 80,
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {},
            child: const Text("Button Widget"),
          ),

          const SizedBox(height: 20),

          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text("Card Widget"),
            ),
          ),
        ],
      ),
    );
  }
}