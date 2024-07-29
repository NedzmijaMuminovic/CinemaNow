// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screening.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Screening _$ScreeningFromJson(Map<String, dynamic> json) => Screening(
      id: (json['id'] as num?)?.toInt(),
      movieId: (json['movieId'] as num?)?.toInt(),
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      time: json['time'] as String?,
      hall: json['hall'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      movie: json['movie'] == null
          ? null
          : Movie.fromJson(json['movie'] as Map<String, dynamic>),
      stateMachine: json['stateMachine'] as String?,
    );

Map<String, dynamic> _$ScreeningToJson(Screening instance) => <String, dynamic>{
      'id': instance.id,
      'movieId': instance.movieId,
      'date': instance.date?.toIso8601String(),
      'time': instance.time,
      'hall': instance.hall,
      'price': instance.price,
      'movie': instance.movie,
      'stateMachine': instance.stateMachine,
    };
