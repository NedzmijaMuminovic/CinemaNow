import 'dart:convert';

import 'package:cinemanow_desktop/models/movie_reservation_seat_count.dart';
import 'package:cinemanow_desktop/models/movie_revenue.dart';
import 'package:http/http.dart' as http;

import 'package:cinemanow_desktop/providers/base_provider.dart';

class ReportProvider extends BaseProvider<Map<String, dynamic>> {
  ReportProvider() : super("Report");

  @override
  Map<String, dynamic> fromJson(data) {
    return data;
  }

  Future<int> getUserCount() async {
    var url = "$baseUrl$endpoint/user-count";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return data['userCount'];
    } else {
      throw Exception("Failed to get user count");
    }
  }

  Future<double> getTotalCinemaIncome() async {
    var url = "$baseUrl$endpoint/total-income";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return data['totalIncome'];
    } else {
      throw Exception("Failed to get total income");
    }
  }

  Future<List<MovieReservationSeatCount>> getTop5WatchedMovies() async {
    var url = "$baseUrl$endpoint/top-5-watched-movies";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    try {
      var response = await http.get(uri, headers: headers);

      if (isValidResponse(response)) {
        var data = jsonDecode(response.body) as List;
        return data
            .map((item) => MovieReservationSeatCount.fromJson(item))
            .toList();
      } else {
        throw Exception("Failed to get top 5 watched movies");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MovieRevenue>> getRevenueByMovie() async {
    var url = "$baseUrl$endpoint/revenue-by-movie";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    try {
      var response = await http.get(uri, headers: headers);

      if (isValidResponse(response)) {
        var data = jsonDecode(response.body) as List;
        return data.map((item) => MovieRevenue.fromJson(item)).toList();
      } else {
        throw Exception("Failed to get movie revenue");
      }
    } catch (e) {
      rethrow;
    }
  }
}
