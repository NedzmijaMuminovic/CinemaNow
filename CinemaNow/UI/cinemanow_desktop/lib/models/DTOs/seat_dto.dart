import 'package:json_annotation/json_annotation.dart';

part 'seat_dto.g.dart';

@JsonSerializable()
class SeatDto {
  int? id;
  String? name;
  bool? isReserved;

  SeatDto({
    this.id,
    this.name,
    this.isReserved,
  });

  factory SeatDto.fromJson(Map<String, dynamic> json) => _$SeatDtoFromJson(json);
  Map<String, dynamic> toJson() => _$SeatDtoToJson(this);
}
