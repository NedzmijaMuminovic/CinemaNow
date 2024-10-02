// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Seat _$SeatFromJson(Map<String, dynamic> json) => Seat(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$SeatToJson(Seat instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
