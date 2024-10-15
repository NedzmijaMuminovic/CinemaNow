import 'package:json_annotation/json_annotation.dart';

part 'top_customer.g.dart';

@JsonSerializable()
class TopCustomer {
  final int userId;
  final String name;
  final String surname;
  final double totalSpent;

  TopCustomer(
      {required this.userId,
      required this.name,
      required this.surname,
      required this.totalSpent});

  factory TopCustomer.fromJson(Map<String, dynamic> json) =>
      _$TopCustomerFromJson(json);
  Map<String, dynamic> toJson() => _$TopCustomerToJson(this);
}
