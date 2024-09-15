// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Movie _$MovieFromJson(Map<String, dynamic> json) => Movie(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String?,
      duration: (json['duration'] as num?)?.toInt(),
      synopsis: json['synopsis'] as String?,
      imageBase64: json['imageBase64'] as String?,
      actors: (json['actors'] as List<dynamic>?)
          ?.map((e) => Actor.fromJson(e as Map<String, dynamic>))
          .toList(),
      genres: (json['genres'] as List<dynamic>?)
          ?.map((e) => Genre.fromJson(e as Map<String, dynamic>))
          .toList(),
      averageRating: (json['averageRating'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$MovieToJson(Movie instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'duration': instance.duration,
      'synopsis': instance.synopsis,
      'imageBase64': instance.imageBase64,
      'actors': instance.actors,
      'genres': instance.genres,
      'averageRating': instance.averageRating,
    };
