import 'dart:convert';

import 'package:cinemanow_mobile/models/hall.dart';
import 'package:cinemanow_mobile/models/movie.dart';
import 'package:cinemanow_mobile/models/screening.dart';
import 'package:cinemanow_mobile/models/search_result.dart';
import 'package:cinemanow_mobile/models/DTOs/seat_dto.dart';
import 'package:cinemanow_mobile/models/view_mode.dart';
import 'package:cinemanow_mobile/providers/base_provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class ScreeningProvider extends BaseProvider<Screening> {
  ScreeningProvider() : super("Screening");

  @override
  Screening fromJson(data) {
    return Screening.fromJson(data);
  }

  Future<SearchResult<Screening>> getScreenings({
    String? fts,
    DateTime? date,
    bool? isGenreIncluded,
  }) async {
    var filter = {
      'IsMovieIncluded': 'true',
      'IsHallIncluded': 'true',
      'IsViewModeIncluded': 'true',
    };

    if (fts != null && fts.isNotEmpty) {
      filter['fts'] = fts;
    }

    if (date != null) {
      filter['date'] = DateFormat('yyyy-MM-dd').format(date);
    }

    if (isGenreIncluded != null) {
      filter['IsGenreIncluded'] = isGenreIncluded.toString();
    }

    return await get(filter: filter);
  }

  Future<void> deleteScreening(int id) async {
    await delete(id);
  }

  Future<void> addScreening(
    Movie movie,
    Hall hall,
    ViewMode viewMode,
    DateTime dateTime,
    double price,
  ) async {
    final newScreening = {
      'movieId': movie.id,
      'hallId': hall.id,
      'viewModeId': viewMode.id,
      'dateTime': dateTime.toIso8601String(),
      'price': price,
    };

    await insert(newScreening);
  }

  Future<void> updateScreening(
    int id,
    Movie movie,
    Hall hall,
    ViewMode viewMode,
    DateTime dateTime,
    double price,
  ) async {
    final updatedScreening = {
      'movieId': movie.id,
      'hallId': hall.id,
      'viewModeId': viewMode.id,
      'dateTime': dateTime.toIso8601String(),
      'price': price,
    };

    await update(id, updatedScreening);
  }

  Future<Screening> getScreeningById(int id) async {
    var url = "$baseUrl$endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return Screening.fromJson(data);
    } else {
      throw Exception("Failed to get screening by ID");
    }
  }

  Future<void> hideScreening(int id) async {
    var url = "$baseUrl$endpoint/$id/hide";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.put(uri, headers: headers);

    if (isValidResponse(response)) {
      notifyListeners();
    } else {
      throw Exception("Failed to hide screening");
    }
  }

  Future<void> activateScreening(int id) async {
    var url = "$baseUrl$endpoint/$id/activate";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.put(uri, headers: headers);

    if (isValidResponse(response)) {
      notifyListeners();
    } else {
      throw Exception("Failed to activate screening");
    }
  }

  Future<List<Screening>> getScreeningsByMovieId(int movieId,
      {DateTime? date}) async {
    var url = "$baseUrl$endpoint/ByMovie/$movieId";
    if (date != null) {
      var dateString = date.toIso8601String().split('T')[0];
      url += "?date=$dateString";
    }
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body) as List;
      return data.map((item) => Screening.fromJson(item)).toList();
    } else {
      throw Exception("Failed to get screenings for movie");
    }
  }

  Future<List<SeatDto>> getSeatsForScreening(int screeningId) async {
    var url = "$baseUrl$endpoint/$screeningId/seats";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    try {
      var response = await http.get(uri, headers: headers);

      if (isValidResponse(response)) {
        var data = jsonDecode(response.body) as List;
        return data
            .map((item) {
              try {
                return SeatDto.fromJson(item);
              } catch (e) {
                return null;
              }
            })
            .whereType<SeatDto>()
            .toList();
      } else {
        throw Exception(
            "Failed to get seats for screening: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to get seats for screening: $e");
    }
  }
}
