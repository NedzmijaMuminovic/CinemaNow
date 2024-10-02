import 'package:cinemanow_desktop/models/search_result.dart';
import 'package:cinemanow_desktop/models/seat.dart';
import 'package:cinemanow_desktop/providers/base_provider.dart';

class SeatProvider extends BaseProvider<Seat> {
  SeatProvider() : super("Seat");

  @override
  Seat fromJson(data) {
    return Seat.fromJson(data);
  }

  Future<SearchResult<Seat>> getSeats({dynamic filter}) async {
    return await get(filter: filter);
  }

  Future<void> deleteSeat(int id) async {
    await delete(id);
  }
}
