import 'dart:convert';
import 'package:cinemanow_desktop/models/rating.dart';
import 'package:cinemanow_desktop/providers/auth_provider.dart';
import 'package:cinemanow_desktop/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class RatingProvider extends BaseProvider<Rating> {
  RatingProvider() : super("Rating");

  @override
  Rating fromJson(data) {
    return Rating.fromJson(data);
  }

  Future<double?> getAverageRating(int movieId) async {
    var url = "$baseUrl$endpoint/average/$movieId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    try {
      var response = await http.get(uri, headers: headers);

      if (isValidResponse(response)) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['averageRating'] != null) {
          return jsonResponse['averageRating'].toDouble();
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<List<Rating>> getByMovieId(int movieId) async {
    var url = "$baseUrl$endpoint/movie/$movieId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    try {
      var response = await http.get(uri, headers: headers);

      if (isValidResponse(response)) {
        var jsonResponse = jsonDecode(response.body) as List;
        return jsonResponse.map((data) => Rating.fromJson(data)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<Rating> addRating(Rating rating) async {
    try {
      return await insert(rating);
    } catch (e) {
      if (e.toString().contains("You have already rated this movie")) {
        throw Exception('You have already rated this movie.');
      }
      throw Exception('Failed to add rating: ${e.toString()}');
    }
  }

  Future<void> deleteRating(int ratingId) async {
    try {
      await delete(ratingId);
    } catch (e) {
      throw Exception('Failed to delete rating: ${e.toString()}');
    }
  }

  Future<Rating> updateRating(int ratingId, Rating updatedRating) async {
    try {
      return await update(ratingId, updatedRating);
    } catch (e) {
      throw Exception('Failed to update rating: ${e.toString()}');
    }
  }

  Future<bool> hasUserRatedMovie(int movieId) async {
    final userId = AuthProvider.userId;
    if (userId == null) {
      return false;
    }

    var url = "$baseUrl$endpoint/hasRated/$userId/$movieId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    try {
      var response = await http.get(uri, headers: headers);

      if (isValidResponse(response)) {
        var jsonResponse = jsonDecode(response.body);

        return jsonResponse['hasRated'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
