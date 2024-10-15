// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_customer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TopCustomer _$TopCustomerFromJson(Map<String, dynamic> json) => TopCustomer(
      userId: (json['userId'] as num).toInt(),
      name: json['name'] as String,
      surname: json['surname'] as String,
      totalSpent: (json['totalSpent'] as num).toDouble(),
    );

Map<String, dynamic> _$TopCustomerToJson(TopCustomer instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'name': instance.name,
      'surname': instance.surname,
      'totalSpent': instance.totalSpent,
    };
