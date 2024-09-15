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

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return data?.toDouble();
    } else {
      throw Exception("Failed to load average rating");
    }
  }
}
