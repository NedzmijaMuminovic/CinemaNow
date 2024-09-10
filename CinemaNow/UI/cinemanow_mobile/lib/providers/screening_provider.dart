import 'package:cinemanow_mobile/models/hall.dart';
import 'package:cinemanow_mobile/models/movie.dart';
import 'package:cinemanow_mobile/models/screening.dart';
import 'package:cinemanow_mobile/models/search_result.dart';
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
    return await getById(id);
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
}
