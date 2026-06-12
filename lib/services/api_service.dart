import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user.dart';

class ApiService {
  static Future<List<User>> fetchUsers()
  async {
    final response = await http.get(
      Uri.parse(
        "https://jsonplaceholder.typicode.com/users",
      ),
    );

    final List<dynamic> data =
        jsonDecode(response.body);

    return data
        .map((e) => User.fromJson(e))
        .toList();
  }
}
