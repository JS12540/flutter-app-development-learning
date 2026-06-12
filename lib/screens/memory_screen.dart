/*
=============================================================================

MEMORY LESSON

Widget
 ↓
Element
 ↓
RenderObject

Widgets are IMMUTABLE.

Flutter rebuilds Widgets often.

This is cheap.

The changing data usually lives in State.

=============================================================================
*/

import 'package:flutter/material.dart';

class MemoryScreen extends StatelessWidget {
  const MemoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Memory"),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: SelectableText(
'''
Widget Tree

Scaffold
 └── Column
      ├── Text
      ├── Text
      └── Button

Flutter internally creates:

Widget
  ↓
Element
  ↓
RenderObject

Widgets:
- Immutable
- Lightweight
- Rebuilt often

State:
- Lives in State object
- Stores mutable data

Images consume much more memory
than Text widgets because image
bytes are stored in memory.

ListView.builder saves memory
because only visible rows are
created.

''',
        ),
      ),
    );
  }
}