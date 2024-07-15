import 'package:json_annotation/json_annotation.dart';

part 'screening.g.dart';

@JsonSerializable()
class Screening {
  @JsonKey(name: 'id')
  int? screeningID;
  String? hall;

  Screening({this.screeningID, this.hall});

  /// Connect the generated [_$PersonFromJson] function to the `fromJson`
  /// factory.
  factory Screening.fromJson(Map<String, dynamic> json) =>
      _$ScreeningFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$ScreeningToJson(this);
}
