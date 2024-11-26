import 'package:cinemanow_desktop/models/DTOs/seat_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reservation_seat.g.dart';

@JsonSerializable()
class ReservationSeat {
  int? reservationId;
  int? seatId;
  SeatDto? seat;

  ReservationSeat({
    this.reservationId,
    this.seatId,
    this.seat,
  });

  factory ReservationSeat.fromJson(Map<String, dynamic> json) =>
      _$ReservationSeatFromJson(json);
  Map<String, dynamic> toJson() => _$ReservationSeatToJson(this);
}
