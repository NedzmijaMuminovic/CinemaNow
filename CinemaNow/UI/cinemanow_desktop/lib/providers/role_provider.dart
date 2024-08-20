import 'package:cinemanow_desktop/models/role.dart';
import 'package:cinemanow_desktop/providers/base_provider.dart';

class RoleProvider extends BaseProvider<Role> {
  RoleProvider() : super("Role");

  @override
  Role fromJson(data) {
    return Role.fromJson(data);
  }

  Future<Role> fetchRoleByName(String roleName) async {
    var result = await get(filter: {"name": roleName});

    var filteredRoles =
        result.result.where((role) => role.name == roleName).toList();

    if (filteredRoles.isNotEmpty) {
      return filteredRoles.first;
    } else {
      throw Exception("Role not found");
    }
  }
}
