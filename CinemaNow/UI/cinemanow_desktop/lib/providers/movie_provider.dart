import 'package:cinemanow_desktop/models/movie.dart';
import 'package:cinemanow_desktop/models/search_result.dart';
import 'package:cinemanow_desktop/providers/base_provider.dart';

class MovieProvider extends BaseProvider<Movie> {
  MovieProvider() : super("Movie");

  @override
  Movie fromJson(data) {
    return Movie.fromJson(data);
  }

  Future<SearchResult<Movie>> getMovies({dynamic filter}) async {
    return await get(filter: filter);
  }

  Future<void> deleteMovie(int id) async {
    await delete(id);
  }
}
