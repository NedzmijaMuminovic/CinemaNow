import 'package:json_annotation/json_annotation.dart';
import 'movie.dart';

part 'screening.g.dart';

@JsonSerializable()
class Screening {
  int? id;
  int? movieId;
  DateTime? date;
  String? time; //???
  String? hall;
  double? price;
  Movie? movie;
  String? stateMachine;

  Screening(
      {this.id,
      this.movieId,
      this.date,
      this.time,
      this.hall,
      this.price,
      this.movie,
      this.stateMachine});

  /// Connect the generated [_$PersonFromJson] function to the `fromJson`
  /// factory.
  factory Screening.fromJson(Map<String, dynamic> json) =>
      _$ScreeningFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$ScreeningToJson(this);
}
