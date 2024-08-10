import 'package:cinemanow_desktop/models/actor.dart';
import 'package:cinemanow_desktop/models/search_result.dart';
import 'package:cinemanow_desktop/providers/base_provider.dart';

class ActorProvider extends BaseProvider<Actor> {
  ActorProvider() : super("Actor");

  @override
  Actor fromJson(data) {
    return Actor.fromJson(data);
  }

  Future<SearchResult<Actor>> getActors(
      {String? nameGTE, String? surnameGTE}) async {
    final filter = <String, dynamic>{};
    if (nameGTE != null && nameGTE.isNotEmpty) {
      filter['namegte'] = nameGTE;
    }

    if (surnameGTE != null && surnameGTE.isNotEmpty) {
      filter['surnamegte'] = surnameGTE;
    }
    return await get(filter: filter);
  }

  Future<void> deleteActor(int id) async {
    await delete(id);
  }

  Future<Actor> getActorById(int id) async {
    return await getById(id);
  }

  Future<void> addActor(
    String name,
    String surname,
    String? imageBase64,
  ) async {
    final newActor = {
      'name': name,
      'surname': surname,
      'imageBase64': imageBase64,
    };

    await insert(newActor);
  }

  Future<void> updateActor(
    int id,
    String name,
    String surname,
    String? imageBase64,
  ) async {
    final updatedActor = {
      'name': name,
      'surname': surname,
      'imageBase64': imageBase64,
    };

    await update(id, updatedActor);
  }
}
