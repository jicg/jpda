
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jpda/comm/jpda.dart';
import 'package:jpda/pages/comm/base/query_search.dart';

class QueryProductPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return QueryBaseWidget(
      delegate: QueryProductDelegate(),
    );
  }
}

class QueryProductDelegate extends QueryBeanDelegate {
  @override
  Future<Map> query(BuildContext context,String query, int page) {
    return JPda.web
        .query2("jpda_comm\$query_product", {"page": page, "query": query},context);
  }

  @override
  String get hintText => "款号编号/款号名称";

  @override
  String get title => "款号查询";
}
