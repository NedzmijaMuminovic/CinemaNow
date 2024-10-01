import 'package:json_annotation/json_annotation.dart';

part 'reservation_movie_dto.g.dart';

@JsonSerializable()
class ReservationMovieDto {
  final int reservationId;
  final DateTime reservationDate;
  final int screeningId;
  final DateTime screeningDate;
  final List<int> seatIds;
  final int movieId;
  final String? movieTitle;
  final int? movieDuration;
  final String? movieSynopsis;
  final String? movieImageBase64;

  ReservationMovieDto({
    required this.reservationId,
    required this.reservationDate,
    required this.screeningId,
    required this.screeningDate,
    required this.seatIds,
    required this.movieId,
    this.movieTitle,
    this.movieDuration,
    this.movieSynopsis,
    this.movieImageBase64,
  });

  factory ReservationMovieDto.fromJson(Map<String, dynamic> json) =>
      _$ReservationMovieDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReservationMovieDtoToJson(this);
}
