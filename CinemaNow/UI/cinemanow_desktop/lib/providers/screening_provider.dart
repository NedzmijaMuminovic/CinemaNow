import 'package:cinemanow_desktop/models/hall.dart';
import 'package:cinemanow_desktop/models/movie.dart';
import 'package:cinemanow_desktop/models/screening.dart';
import 'package:cinemanow_desktop/models/search_result.dart';
import 'package:cinemanow_desktop/models/view_mode.dart';
import 'package:cinemanow_desktop/providers/base_provider.dart';
import 'package:intl/intl.dart';

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
}
