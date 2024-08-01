import 'package:cinemanow_desktop/models/screening.dart';
import 'package:cinemanow_desktop/models/search_result.dart';
import 'package:cinemanow_desktop/providers/base_provider.dart';

class ScreeningProvider extends BaseProvider<Screening> {
  ScreeningProvider() : super("Screening");

  @override
  Screening fromJson(data) {
    return Screening.fromJson(data);
  }

  Future<SearchResult<Screening>> getScreenings({dynamic filter}) async {
    filter ??= {};
    filter['IsMovieIncluded'] = 'true';

    return await get(filter: filter);
  }

  Future<void> deleteScreening(int id) async {
    await delete(id);
  }
}
