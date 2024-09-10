import 'package:json_annotation/json_annotation.dart';

part 'view_mode.g.dart';

@JsonSerializable()
class ViewMode {
  int? id;
  String? name;

  ViewMode({this.id, this.name});

  factory ViewMode.fromJson(Map<String, dynamic> json) =>
      _$ViewModeFromJson(json);
  Map<String, dynamic> toJson() => _$ViewModeToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ViewMode && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
