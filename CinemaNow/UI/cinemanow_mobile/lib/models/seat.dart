import 'package:json_annotation/json_annotation.dart';

part 'seat.g.dart';

@JsonSerializable()
class Seat {
  final int seatId;
  final String seatName;
  final bool isReserved;

  Seat({
    required this.seatId,
    required this.seatName,
    required this.isReserved,
  });

  factory Seat.fromJson(Map<String, dynamic> json) => _$SeatFromJson(json);
  Map<String, dynamic> toJson() => _$SeatToJson(this);
}
