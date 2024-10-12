// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_reservation_seat_count.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MovieReservationSeatCount _$MovieReservationSeatCountFromJson(
        Map<String, dynamic> json) =>
    MovieReservationSeatCount(
      movieId: (json['movieId'] as num).toInt(),
      movieTitle: json['movieTitle'] as String,
      reservationSeatCount: (json['reservationSeatCount'] as num).toInt(),
    );

Map<String, dynamic> _$MovieReservationSeatCountToJson(
        MovieReservationSeatCount instance) =>
    <String, dynamic>{
      'movieId': instance.movieId,
      'movieTitle': instance.movieTitle,
      'reservationSeatCount': instance.reservationSeatCount,
    };
