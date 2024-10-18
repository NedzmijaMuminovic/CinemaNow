import 'dart:convert';
import 'package:cinemanow_mobile/providers/auth_provider.dart';
import 'package:http/http.dart' as http;

import 'package:cinemanow_mobile/models/actor.dart';
import 'package:cinemanow_mobile/models/genre.dart';
import 'package:cinemanow_mobile/models/movie.dart';
import 'package:cinemanow_mobile/models/search_result.dart';
import 'package:cinemanow_mobile/providers/base_provider.dart';
import 'package:cinemanow_mobile/providers/rating_provider.dart';

class MovieProvider extends BaseProvider<Movie> {
  final RatingProvider _ratingProvider;

  MovieProvider(this._ratingProvider) : super("Movie");

  @override
  Movie fromJson(data) {
    return Movie.fromJson(data);
  }

  Future<SearchResult<Movie>> getMovies({String? fts}) async {
    var filter = {
      'IsGenreIncluded': 'true',
      'IsActorIncluded': 'true',
    };
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
    List<Actor>? actors,
    List<Genre>? genres,
  ) async {
    final newMovie = {
      'title': title,
      'duration': duration,
      'synopsis': synopsis,
      'imageBase64': imageBase64,
      'actorIds': actors?.map((actor) => actor.id).toList() ?? [],
      'genreIds': genres?.map((genre) => genre.id).toList() ?? [],
    };

    await insert(newMovie);
  }

  Future<void> updateMovie(
    int id,
    String title,
    int duration,
    String synopsis,
    String? imageBase64,
    List<Actor>? actors,
    List<Genre>? genres,
  ) async {
    final updatedMovie = {
      'title': title,
      'duration': duration,
      'synopsis': synopsis,
      'imageBase64': imageBase64,
      'actorIds': actors?.map((actor) => actor.id).toList() ?? [],
      'genreIds': genres?.map((genre) => genre.id).toList() ?? [],
    };

    await update(id, updatedMovie);
  }

  @override
  Future<Movie> getById(int id) async {
    Movie movie = await super.getById(id);
    double? averageRating = await _ratingProvider.getAverageRating(id);
    movie.averageRating = averageRating;
    return movie;
  }

  Future<Map<String, String>> getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (AuthProvider.username != null && AuthProvider.password != null) {
      final credentials = base64Encode(
        utf8.encode('${AuthProvider.username}:${AuthProvider.password}'),
      );
      headers['Authorization'] = 'Basic $credentials';
    }

    return headers;
  }

  Future<List<Movie>> getRecommendations(int movieId) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint/$movieId/recommendations');
      final headers = await getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data.map((item) => Movie.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to fetch recommendations: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
