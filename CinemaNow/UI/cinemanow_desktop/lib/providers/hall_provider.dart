import 'package:cinemanow_desktop/models/hall.dart';
import 'package:cinemanow_desktop/models/search_result.dart';
import 'package:cinemanow_desktop/providers/base_provider.dart';

class HallProvider extends BaseProvider<Hall> {
  HallProvider() : super("Hall");

  @override
  Hall fromJson(data) {
    return Hall.fromJson(data);
  }

  Future<SearchResult<Hall>> getHalls({dynamic filter}) async {
    return await get(filter: filter);
  }

  Future<void> deleteHall(int id) async {
    await delete(id);
  }
}
