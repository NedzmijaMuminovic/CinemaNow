import 'package:cinemanow_mobile/models/actor.dart';
import 'package:cinemanow_mobile/models/genre.dart';
import 'package:json_annotation/json_annotation.dart';

part 'movie.g.dart';

@JsonSerializable()
class Movie {
  int? id;
  String? title;
  int? duration;
  String? synopsis;
  String? imageBase64;
  List<Actor>? actors;
  List<Genre>? genres;
  double? averageRating;

  Movie({
    this.id,
    this.title,
    this.duration,
    this.synopsis,
    this.imageBase64,
    this.actors,
    this.genres,
    this.averageRating,
  });

  factory Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);
  Map<String, dynamic> toJson() => _$MovieToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Movie && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
