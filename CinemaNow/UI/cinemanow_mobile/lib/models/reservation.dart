import 'package:cinemanow_mobile/models/reservation_seat.dart';
import 'package:cinemanow_mobile/models/screening.dart';
import 'package:cinemanow_mobile/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reservation.g.dart';

@JsonSerializable()
class Reservation {
  int? id;
  int? userId;
  int? screeningId;
  DateTime? dateTime;
  int? numberOfTickets;
  double? totalPrice;
  List<ReservationSeat>? seats;
  User? user;
  Screening? screening;

  Reservation({
    this.id,
    this.userId,
    this.screeningId,
    this.dateTime,
    this.numberOfTickets,
    this.totalPrice,
    this.seats,
    this.user,
    this.screening,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) =>
      _$ReservationFromJson(json);
  Map<String, dynamic> toJson() => _$ReservationToJson(this);
}
