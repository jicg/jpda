// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'query_bean.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QueryBean _$QueryBeanFromJson(Map<String, dynamic> json) {
  return QueryBean(json['id'] as int, json['code'] as String,
      json['name'] as String, json['desc'] as String);
}

Map<String, dynamic> _$QueryBeanToJson(QueryBean instance) => <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'desc': instance.desc
    };
