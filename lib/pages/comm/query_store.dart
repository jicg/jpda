import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jpda/comm/jpda.dart';
import 'package:jpda/pages/comm/base/query_comm.dart';

class QueryStorePage extends StatefulWidget {
  @override
  _QueryStorePageState createState() => _QueryStorePageState();
}

class _QueryStorePageState extends State<QueryStorePage> {
  @override
  Widget build(BuildContext context) {
    return QueryBaseWidget(delegate: QueryStoreDelegate());
  }
}

class QueryStoreDelegate extends QueryBeanDelegate {
  @override
  // TODO: implement hintText
  String get hintText => "店仓名称/店仓编号";

  @override
  Future<Response<Map>> query(BuildContext context, String query, int page) {
    // TODO: implement query
    return JPda.web.query(
        context, "jpda_comm\$query_store", {"query": query, "page": page});
  }

  @override
  // TODO: implement title
  String get title => "店仓查询";
}
