// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_movie_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReservationMovieDto _$ReservationMovieDtoFromJson(Map<String, dynamic> json) =>
    ReservationMovieDto(
      reservationId: (json['reservationId'] as num).toInt(),
      reservationDate: DateTime.parse(json['reservationDate'] as String),
      screeningId: (json['screeningId'] as num).toInt(),
      screeningDate: DateTime.parse(json['screeningDate'] as String),
      seatIds: (json['seatIds'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      movieId: (json['movieId'] as num).toInt(),
      movieTitle: json['movieTitle'] as String?,
      movieDuration: (json['movieDuration'] as num?)?.toInt(),
      movieSynopsis: json['movieSynopsis'] as String?,
      movieImageBase64: json['movieImageBase64'] as String?,
    );

Map<String, dynamic> _$ReservationMovieDtoToJson(
        ReservationMovieDto instance) =>
    <String, dynamic>{
      'reservationId': instance.reservationId,
      'reservationDate': instance.reservationDate.toIso8601String(),
      'screeningId': instance.screeningId,
      'screeningDate': instance.screeningDate.toIso8601String(),
      'seatIds': instance.seatIds,
      'movieId': instance.movieId,
      'movieTitle': instance.movieTitle,
      'movieDuration': instance.movieDuration,
      'movieSynopsis': instance.movieSynopsis,
      'movieImageBase64': instance.movieImageBase64,
    };
