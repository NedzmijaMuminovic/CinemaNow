import 'package:cinemanow_desktop/models/hall.dart';
import 'package:cinemanow_desktop/models/view_mode.dart';
import 'package:json_annotation/json_annotation.dart';
import 'movie.dart';

part 'screening.g.dart';

@JsonSerializable()
class Screening {
  int? id;
  int? movieId;
  int? hallId;
  int? viewModeId;
  DateTime? date;
  String? time;
  double? price;
  Movie? movie;
  Hall? hall;
  ViewMode? viewMode;
  String? stateMachine;

  Screening(
      {this.id,
      this.movieId,
      this.date,
      this.time,
      this.price,
      this.movie,
      this.hall,
      this.viewMode,
      this.stateMachine});

  /// Connect the generated [_$PersonFromJson] function to the `fromJson`
  /// factory.
  factory Screening.fromJson(Map<String, dynamic> json) =>
      _$ScreeningFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$ScreeningToJson(this);
}
