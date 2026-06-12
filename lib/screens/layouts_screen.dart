/*
=============================================================================

LAYOUT LESSON

Column = Vertical

Row = Horizontal

Container = Box

=============================================================================
*/

import 'package:flutter/material.dart';

class LayoutsScreen extends StatelessWidget {
  const LayoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Layouts"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              height: 80,
              color: Colors.blue,
              child: const Center(
                child: Text("Container"),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly,
              children: const [
                Icon(Icons.home),
                Icon(Icons.person),
                Icon(Icons.settings),
              ],
            ),

            const SizedBox(height: 20),

            Column(
              children: const [
                Text("Column Item 1"),
                Text("Column Item 2"),
                Text("Column Item 3"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}