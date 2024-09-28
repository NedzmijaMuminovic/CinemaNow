import 'package:json_annotation/json_annotation.dart';

part 'seat.g.dart';

@JsonSerializable()
class Seat {
  int? seatId;
  String? seatName;
  bool? isReserved;

  Seat({
    this.seatId,
    this.seatName,
    this.isReserved,
  });

  factory Seat.fromJson(Map<String, dynamic> json) => _$SeatFromJson(json);
  Map<String, dynamic> toJson() => _$SeatToJson(this);
}
