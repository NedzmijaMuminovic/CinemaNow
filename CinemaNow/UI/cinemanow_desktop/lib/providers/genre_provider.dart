import 'package:cinemanow_desktop/models/genre.dart';
import 'package:cinemanow_desktop/models/search_result.dart';
import 'package:cinemanow_desktop/providers/base_provider.dart';

class GenreProvider extends BaseProvider<Genre> {
  GenreProvider() : super("Genre");

  @override
  Genre fromJson(data) {
    return Genre.fromJson(data);
  }

  Future<SearchResult<Genre>> getGenres({dynamic filter}) async {
    return await get(filter: filter);
  }

  Future<void> deleteGenre(int id) async {
    await delete(id);
  }
}
