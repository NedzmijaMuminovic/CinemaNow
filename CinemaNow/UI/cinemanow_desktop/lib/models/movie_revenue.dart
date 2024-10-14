import 'package:json_annotation/json_annotation.dart';

part 'movie_revenue.g.dart';

@JsonSerializable()
class MovieRevenue {
  final int movieId;
  final String movieTitle;
  final double totalRevenue;

  MovieRevenue(
      {required this.movieId,
      required this.movieTitle,
      required this.totalRevenue});

  factory MovieRevenue.fromJson(Map<String, dynamic> json) =>
      _$MovieRevenueFromJson(json);
  Map<String, dynamic> toJson() => _$MovieRevenueToJson(this);
}
