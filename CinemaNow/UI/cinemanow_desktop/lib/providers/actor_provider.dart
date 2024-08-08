import 'package:cinemanow_desktop/models/actor.dart';
import 'package:cinemanow_desktop/models/search_result.dart';
import 'package:cinemanow_desktop/providers/base_provider.dart';

class ActorProvider extends BaseProvider<Actor> {
  ActorProvider() : super("Actor");

  @override
  Actor fromJson(data) {
    return Actor.fromJson(data);
  }

  Future<SearchResult<Actor>> getActors({dynamic filter}) async {
    return await get(filter: filter);
  }

  Future<void> deleteHall(int id) async {
    await delete(id);
  }
}
