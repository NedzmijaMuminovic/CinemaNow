import 'package:cinemanow_mobile/models/role.dart';
import 'package:cinemanow_mobile/providers/role_provider.dart';
import 'package:cinemanow_mobile/providers/user_provider.dart';

import 'base_provider.dart';

class RegistrationProvider extends BaseProvider {
  final RoleProvider _roleProvider = RoleProvider();

  RegistrationProvider() : super("User");

  Future<int?> getUserRoleId() async {
    try {
      Role userRole = await _roleProvider.fetchRoleByName("User");
      return userRole.id;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isUsernameTaken(String username) async {
    final userProvider = UserProvider();
    final users = await userProvider.getUsers();
    return users.result.any((user) => user.username == username);
  }

  Future<bool> registerUser({
    required String name,
    required String surname,
    required String email,
    required String username,
    required String password,
    required String passwordConfirmation,
  }) async {
    if (await isUsernameTaken(username)) {
      return false;
    }

    final userRoleId = await getUserRoleId();
    if (userRoleId == null) {
      return false;
    }

    final userPayload = {
      'name': name,
      'surname': surname,
      'email': email,
      'username': username,
      'password': password,
      'passwordConfirmation': passwordConfirmation,
      'roleIds': [userRoleId],
    };

    final response = await insert(userPayload);

    return response != null;
  }

  @override
  Map<String, String> createHeaders() {
    return {
      "Content-Type": "application/json",
    };
  }

  @override
  dynamic fromJson(data) {
    return data;
  }
}