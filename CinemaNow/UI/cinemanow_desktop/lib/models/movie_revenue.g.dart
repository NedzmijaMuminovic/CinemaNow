// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_revenue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MovieRevenue _$MovieRevenueFromJson(Map<String, dynamic> json) => MovieRevenue(
      movieId: (json['movieId'] as num).toInt(),
      movieTitle: json['movieTitle'] as String,
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
    );

Map<String, dynamic> _$MovieRevenueToJson(MovieRevenue instance) =>
    <String, dynamic>{
      'movieId': instance.movieId,
      'movieTitle': instance.movieTitle,
      'totalRevenue': instance.totalRevenue,
    };
