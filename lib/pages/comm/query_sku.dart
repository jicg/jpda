
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jpda/comm/jpda.dart';
import 'package:jpda/pages/comm/base/query_search.dart';

class QuerySkuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return QueryBaseWidget(
      delegate: QueryProductDelegate(),
    );
  }
}

class QueryProductDelegate extends QueryBeanDelegate {
  @override
  Future<Response<Map>> query(BuildContext context,String query, int page) {
    return JPda.web
        .query(context,"jpda_comm\$query_sku", {"page": page, "query": query});
  }

  @override
  String get hintText => "条码/款号编号/款号名称";

  @override
  String get title => "条码查询";
}
