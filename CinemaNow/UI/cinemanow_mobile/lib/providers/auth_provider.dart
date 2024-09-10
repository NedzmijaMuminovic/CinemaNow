import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:cinemanow_mobile/models/user.dart';
import 'package:cinemanow_mobile/providers/base_provider.dart';

class AuthProvider extends BaseProvider<User> {
  AuthProvider() : super("User");

  static String? username;
  static String? password;
  static int? userId;

  static void setUser(User user) {
    userId = user.id;
  }

  Future<User?> login(String username, String password) async {
    try {
      final url = Uri.parse("${baseUrl}User/login");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final user = User.fromJson(jsonDecode(response.body));
        return user;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
