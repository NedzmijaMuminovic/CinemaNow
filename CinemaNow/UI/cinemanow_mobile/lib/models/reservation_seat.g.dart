// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_seat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReservationSeat _$ReservationSeatFromJson(Map<String, dynamic> json) =>
    ReservationSeat(
      reservationId: (json['reservationId'] as num?)?.toInt(),
      seatId: (json['seatId'] as num?)?.toInt(),
      seat: json['seat'] == null
          ? null
          : Seat.fromJson(json['seat'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReservationSeatToJson(ReservationSeat instance) =>
    <String, dynamic>{
      'reservationId': instance.reservationId,
      'seatId': instance.seatId,
      'seat': instance.seat,
    };
