import 'package:json_annotation/json_annotation.dart';

part 'hall.g.dart';

@JsonSerializable()
class Hall {
  int? id;
  String? name;

  Hall({this.id, this.name});

  factory Hall.fromJson(Map<String, dynamic> json) => _$HallFromJson(json);
  Map<String, dynamic> toJson() => _$HallToJson(this);
}
