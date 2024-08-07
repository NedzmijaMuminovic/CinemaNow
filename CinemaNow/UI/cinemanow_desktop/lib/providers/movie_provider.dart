import 'package:cinemanow_desktop/models/movie.dart';
import 'package:cinemanow_desktop/models/search_result.dart';
import 'package:cinemanow_desktop/providers/base_provider.dart';

class MovieProvider extends BaseProvider<Movie> {
  MovieProvider() : super("Movie");

  @override
  Movie fromJson(data) {
    return Movie.fromJson(data);
  }

  Future<SearchResult<Movie>> getMovies({String? fts}) async {
    final filter = <String, dynamic>{};
    if (fts != null && fts.isNotEmpty) {
      filter['fts'] = fts;
    }
    return await get(filter: filter);
  }

  Future<void> deleteMovie(int id) async {
    await delete(id);
  }

  Future<void> addMovie(
    String title,
    int duration,
    String synopsis,
    String? imageBase64,
  ) async {
    final newMovie = {
      'title': title,
      'duration': duration,
      'synopsis': synopsis,
      'imageBase64': imageBase64,
    };

    await insert(newMovie);
  }

  Future<void> updateMovie(
    int id,
    String title,
    int duration,
    String synopsis,
    String? imageBase64,
  ) async {
    final updatedMovie = {
      'title': title,
      'duration': duration,
      'synopsis': synopsis,
      'imageBase64': imageBase64,
    };

    await update(id, updatedMovie);
  }

  Future<Movie> getMovieById(int id) async {
    return await getById(id);
  }
}
