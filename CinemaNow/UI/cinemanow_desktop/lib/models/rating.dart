import 'package:cinemanow_desktop/models/movie.dart';
import 'package:cinemanow_desktop/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rating.g.dart';

@JsonSerializable()
class Rating {
  int? id;
  int? userId;
  int? movieId;
  User? user;
  Movie? movie;
  int? value;
  String? comment;

  Rating(
      {this.id,
      this.userId,
      this.movieId,
      this.user,
      this.movie,
      this.value,
      this.comment});

  factory Rating.fromJson(Map<String, dynamic> json) => _$RatingFromJson(json);
  Map<String, dynamic> toJson() => _$RatingToJson(this);
}
