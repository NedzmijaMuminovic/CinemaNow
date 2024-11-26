// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seat_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SeatDto _$SeatDtoFromJson(Map<String, dynamic> json) => SeatDto(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      isReserved: json['isReserved'] as bool?,
    );

Map<String, dynamic> _$SeatDtoToJson(SeatDto instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'isReserved': instance.isReserved,
    };
