// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Seat _$SeatFromJson(Map<String, dynamic> json) => Seat(
      seatId: (json['seatId'] as num?)?.toInt(),
      seatName: json['seatName'] as String?,
      isReserved: json['isReserved'] as bool?,
    );

Map<String, dynamic> _$SeatToJson(Seat instance) => <String, dynamic>{
      'seatId': instance.seatId,
      'seatName': instance.seatName,
      'isReserved': instance.isReserved,
    };
