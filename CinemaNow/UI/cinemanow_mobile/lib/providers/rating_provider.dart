import 'dart:convert';
import 'package:cinemanow_mobile/models/rating.dart';
import 'package:cinemanow_mobile/providers/base_provider.dart';
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
      throw Exception('Failed to add rating: ${e.toString()}');
    }
  }
}
