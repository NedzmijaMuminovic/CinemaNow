import 'package:json_annotation/json_annotation.dart';

part 'movie.g.dart';

@JsonSerializable()
class Movie {
  int? id;
  String? title;
  int? duration;
  String? synopsis;

  Movie({this.id, this.title, this.duration, this.synopsis});

  factory Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);
  Map<String, dynamic> toJson() => _$MovieToJson(this);
}
