import 'package:cinemanow_desktop/models/user.dart';

class AuthProvider {
  static String? username;
  static String? password;
  static int? userId;

  static void setUser(User user) {
    userId = user.id;
  }
}
