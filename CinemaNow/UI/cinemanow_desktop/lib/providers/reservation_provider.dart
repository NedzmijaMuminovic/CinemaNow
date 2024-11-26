import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:cinemanow_desktop/models/reservation.dart';
import 'package:cinemanow_desktop/providers/base_provider.dart';

class ReservationProvider extends BaseProvider<Reservation> {
  ReservationProvider() : super("Reservation");

  @override
  Reservation fromJson(data) {
    return Reservation.fromJson(data);
  }

  Future<List<Reservation>> getReservationsByScreeningId(
      int screeningId) async {
    var url = "$baseUrl$endpoint/screening/$screeningId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var decodedResponse = json.decode(response.body) as List;
      return decodedResponse.map((data) => Reservation.fromJson(data)).toList();
    } else {
      throw Exception("Failed to load reservations");
    }
  }

  Future<String> getQRCode(int reservationId) async {
    var url = "$baseUrl$endpoint/$reservationId/qrcode";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      return response.body;
    } else {
      throw Exception("Failed to load QR code");
    }
  }
}
