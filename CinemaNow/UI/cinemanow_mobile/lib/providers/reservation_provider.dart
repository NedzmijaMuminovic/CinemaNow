import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:cinemanow_mobile/models/DTOs/reservation_movie_dto.dart';
import 'package:cinemanow_mobile/models/reservation.dart';
import 'package:cinemanow_mobile/providers/base_provider.dart';

class ReservationProvider extends BaseProvider<Reservation> {
  ReservationProvider() : super("Reservation");

  @override
  Reservation fromJson(data) {
    return Reservation.fromJson(data);
  }

  Future<List<ReservationMovieDto>> getReservationsByUserId(int userId) async {
    var url = "$baseUrl$endpoint/user/$userId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return (data as List)
          .map((item) => ReservationMovieDto.fromJson(item))
          .toList();
    } else {
      throw Exception("Failed to load reservations");
    }
  }
}
