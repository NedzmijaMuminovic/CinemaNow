// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screening.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Screening _$ScreeningFromJson(Map<String, dynamic> json) => Screening(
      id: (json['id'] as num?)?.toInt(),
      movieId: (json['movieId'] as num?)?.toInt(),
      dateTime: json['dateTime'] == null
          ? null
          : DateTime.parse(json['dateTime'] as String),
      price: (json['price'] as num?)?.toDouble(),
      movie: json['movie'] == null
          ? null
          : Movie.fromJson(json['movie'] as Map<String, dynamic>),
      hall: json['hall'] == null
          ? null
          : Hall.fromJson(json['hall'] as Map<String, dynamic>),
      viewMode: json['viewMode'] == null
          ? null
          : ViewMode.fromJson(json['viewMode'] as Map<String, dynamic>),
      stateMachine: json['stateMachine'] as String?,
    )
      ..hallId = (json['hallId'] as num?)?.toInt()
      ..viewModeId = (json['viewModeId'] as num?)?.toInt();

Map<String, dynamic> _$ScreeningToJson(Screening instance) => <String, dynamic>{
      'id': instance.id,
      'movieId': instance.movieId,
      'hallId': instance.hallId,
      'viewModeId': instance.viewModeId,
      'dateTime': instance.dateTime?.toIso8601String(),
      'price': instance.price,
      'movie': instance.movie,
      'hall': instance.hall,
      'viewMode': instance.viewMode,
      'stateMachine': instance.stateMachine,
    };
