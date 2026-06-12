/*
=============================================================================

STATE LESSON

State = data that changes.

setState()

tells Flutter:

"Something changed.
Rebuild UI."

=============================================================================
*/

import 'package:flutter/material.dart';

class StateScreen extends StatefulWidget {
  const StateScreen({super.key});

  @override
  State<StateScreen> createState() =>
      _StateScreenState();
}

class _StateScreenState extends State<StateScreen> {
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("State"),
      ),
      body: Center(
        child: Text(
          "Counter = $counter",
          style: const TextStyle(fontSize: 30),
        ),
      ),
      floatingActionButton:
          FloatingActionButton(
        onPressed: () {
          setState(() {
            counter++;
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}