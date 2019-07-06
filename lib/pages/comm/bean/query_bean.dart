import 'package:json_annotation/json_annotation.dart';

part 'package:jpda/pages/comm/bean/query_bean.g.dart';

@JsonSerializable(nullable: false)
class QueryBean {
  int id;
  String code;
  String name;
  String desc;

  QueryBean(this.id, this.code, this.name, this.desc);

  factory QueryBean.fromJson(Map<String, dynamic> json) => _$QueryBeanFromJson(json);

  Map<String, dynamic> toJson() => _$QueryBeanToJson(this);
}
