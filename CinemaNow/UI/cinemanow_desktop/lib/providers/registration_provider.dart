import 'base_provider.dart';

class RegistrationProvider extends BaseProvider {
  RegistrationProvider() : super("User");

  Future<bool> registerUser({
    required String name,
    required String surname,
    required String email,
    required String username,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await insert({
      'name': name,
      'surname': surname,
      'email': email,
      'username': username,
      'password': password,
      'passwordConfirmation': passwordConfirmation,
      'roleIds': [2],
    });

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
