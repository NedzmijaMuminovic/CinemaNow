// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reservation _$ReservationFromJson(Map<String, dynamic> json) => Reservation(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num?)?.toInt(),
      screeningId: (json['screeningId'] as num?)?.toInt(),
      dateTime: json['dateTime'] == null
          ? null
          : DateTime.parse(json['dateTime'] as String),
      numberOfTickets: (json['numberOfTickets'] as num?)?.toInt(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble(),
      seats: (json['seats'] as List<dynamic>?)
          ?.map((e) => ReservationSeat.fromJson(e as Map<String, dynamic>))
          .toList(),
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      screening: json['screening'] == null
          ? null
          : Screening.fromJson(json['screening'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReservationToJson(Reservation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'screeningId': instance.screeningId,
      'dateTime': instance.dateTime?.toIso8601String(),
      'numberOfTickets': instance.numberOfTickets,
      'totalPrice': instance.totalPrice,
      'seats': instance.seats,
      'user': instance.user,
      'screening': instance.screening,
    };
