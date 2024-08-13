import 'package:cinemanow_desktop/models/user.dart';
import 'package:cinemanow_desktop/models/search_result.dart';
import 'package:cinemanow_desktop/providers/base_provider.dart';

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
