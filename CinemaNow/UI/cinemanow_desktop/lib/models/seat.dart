import 'package:json_annotation/json_annotation.dart';

part 'seat.g.dart';

@JsonSerializable()
class Seat {
  int? id;
  String? name;

  Seat({this.id, this.name});

  factory Seat.fromJson(Map<String, dynamic> json) => _$SeatFromJson(json);
  Map<String, dynamic> toJson() => _$SeatToJson(this);
}
