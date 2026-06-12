/*
=============================================================================

API LESSON

FutureBuilder

waits for Future to complete.

=============================================================================
*/

import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/api_service.dart';

class ApiScreen extends StatelessWidget {
  const ApiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("API"),
      ),
      body: FutureBuilder<List<User>>(
        future: ApiService.fetchUsers(),
        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child:
                  Text(snapshot.error.toString()),
            );
          }

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (_, index) {
              return ListTile(
                title: Text(users[index].name),
              );
            },
          );
        },
      ),
    );
  }
}
