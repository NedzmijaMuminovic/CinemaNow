// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'actor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Actor _$ActorFromJson(Map<String, dynamic> json) => Actor(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      imageBase64: json['imageBase64'] as String?,
    )..surname = json['surname'] as String?;

Map<String, dynamic> _$ActorToJson(Actor instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'surname': instance.surname,
      'imageBase64': instance.imageBase64,
    };
