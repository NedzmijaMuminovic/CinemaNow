import 'package:cinemanow_mobile/models/user.dart';
import 'package:cinemanow_mobile/models/search_result.dart';
import 'package:cinemanow_mobile/providers/base_provider.dart';

class UserProvider extends BaseProvider<User> {
  UserProvider() : super("User");

  @override
  User fromJson(data) {
    return User.fromJson(data);
  }

  Future<SearchResult<User>> getUsers({dynamic filter}) async {
    return await get(filter: filter);
  }

  Future<void> deleteUser(int id) async {
    await delete(id);
  }

  Future<bool> isUsernameTaken(int userId, String username) async {
    final users = await getUsers();
    return users.result
        .any((user) => user.username == username && user.id != userId);
  }

  Future<void> updateUser(
    int id,
    String name,
    String surname,
    String email,
    String username,
    String? password,
    String? passwordConfirmation,
    String? imageBase64,
    List<int> roleIds,
  ) async {
    if (await isUsernameTaken(id, username)) {
      throw Exception('Username is already taken by another user.');
    }

    final updatedUser = {
      'name': name,
      'surname': surname,
      'email': email,
      'username': username,
      'password': password,
      'passwordConfirmation': passwordConfirmation,
      'imageBase64': imageBase64,
      'roleIds': roleIds,
    };

    await update(id, updatedUser);
  }

  Future<User> getUserById(int id) async {
    return await getById(id);
  }
}
