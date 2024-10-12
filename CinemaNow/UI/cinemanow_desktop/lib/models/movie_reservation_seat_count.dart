import 'package:json_annotation/json_annotation.dart';

part 'movie_reservation_seat_count.g.dart';

@JsonSerializable()
class MovieReservationSeatCount {
  final int movieId;
  final String movieTitle;
  final int reservationSeatCount;

  MovieReservationSeatCount({
    required this.movieId,
    required this.movieTitle,
    required this.reservationSeatCount,
  });

  factory MovieReservationSeatCount.fromJson(Map<String, dynamic> json) =>
      _$MovieReservationSeatCountFromJson(json);
  Map<String, dynamic> toJson() => _$MovieReservationSeatCountToJson(this);
}
