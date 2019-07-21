import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jpda/comm/func.dart';
import 'package:jpda/comm/jpda.dart';
import 'package:jpda/pages/comm/base/query_where.dart';
import 'package:jpda/pages/comm/weigets/loading_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class StockHome extends StatefulWidget {
  @override
  _StockHomeState createState() => _StockHomeState();
}

class _StockHomeState extends State<StockHome> {
  static const SkuKey = "sku";
  static const ProductKey = "product";
  static const StoreKey = "store";

  Map _param = {};
  int _page = 1;
  List<Map> _datas = [];
  RefreshController _refreshController;

  bool _loading = false;

  @override
  void initState() {
    _refreshController = RefreshController(initialRefresh: false);
    reLoadData();
    super.initState();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> reLoadData() async {
    try {
      _loading = true;
      _page = 1;
      _param["page"] = _page;
      _datas = [];
      Response<Map> da =
          await JPda.web.query( "jpda_stock\$list", _param,context);
      List dd = json.decode(da.data["data"]);
      List<Map> d = dd.map((f) => f as Map).toList();
      if (d.length > 0) {
        _datas.addAll(d);
        _page++;
      }
    } catch (e) {
      UIUtils.toaskError("$e");
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> loadMoreData() async {
    try {
      _param["page"] = _page;
      Response<Map> da =
          await JPda.web.query( "jpda_stock\$list", _param,context);
      List dd = json.decode(da.data["data"]);
      List<Map> d = dd.map((f) => f as Map).toList();
      if (d.length > 0) {
        _page++;
        _datas.addAll(d);
        setState(() {
          _refreshController.loadComplete();
        });
      } else {
        UIUtils.toaskError("已经没有数据");
        setState(() {
          _refreshController.loadNoData();
        });
      }
    } catch (e) {
      UIUtils.toaskError("$e");
      setState(() {
        _refreshController.loadFailed();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("库存查询"),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.search,
                color: Theme.of(context).primaryIconTheme.color,
              ),
              onPressed: () async {
                var rets = await Navigator.of(context).pushNamed("/stock/query",
                    arguments: QueryPageDataBuilder()
                      ..add(SkuKey, "条码",
                          QueryPageDataBuilder.QUERY_ITEM_INPUT_QUERY,
                          data: {"path": "/comm/query/sku"})
                      ..add(ProductKey, "款号",
                          QueryPageDataBuilder.QUERY_ITEM_INPUT_QUERY,
                          data: {"path": "/comm/query/product"})
                      ..add(StoreKey, "店仓",
                          QueryPageDataBuilder.QUERY_ITEM_INPUT_QUERY,
                          data: {"path": "/comm/query/store"})
//                      ..add(RemarkKey, "备注",
//                          QueryPageDataBuilder.QUERY_ITEM_INPUT)
                    );
                if (rets == null) {
                  return;
                }
//                Map p = {};
//                p[ProductKey] =
//                    QueryPageDataBuilder.formatDataValue(rets, ProductKey);
//                p[StoreKey] =
//                    QueryPageDataBuilder.formatDataValue(rets, StoreKey);
//                p[SkuKey] = QueryPageDataBuilder.formatDataValue(rets, SkuKey);
                _param = rets as Map;
                reLoadData();
              },
              tooltip: "查询",
            ),
          ],
        ),
        body: Container(
          child: LoadingWidget(loading: _loading, child: _buildItems(context)),
        ));
  }

  Widget _buildItems(BuildContext context) {
    if (_datas.length == 0) {
      return Container(
        child: Center(
          child: Text("没有数据"),
        ),
      );
    }
    return SmartRefresher(
      controller: _refreshController,
      child: ListView.separated(
        itemBuilder: (context, i) {
          final Map map = _datas[i];
          return StockItemWidget(
            data: map,
          );
        },
        separatorBuilder: (context, i) {
          return Divider(
            height: 0,
          );
        },
        itemCount: _datas.length,
      ),
      enablePullDown: false,
      enablePullUp: true,
      onLoading: () async {
        await loadMoreData();
      },
    );
  }
}

class StockItemWidget extends StatelessWidget {
  final Map data;

  const StockItemWidget({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "店仓：${data['STORENAME']}",
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      "条码：${data['SKUNO']}",
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      "款号：${data['SKUNAME']}",
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      "名称：${data['SKUVALUE']}",
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      "颜色：${data['COLNAME']}",
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      "尺寸：${data['SIZENAME']}",
                      style: TextStyle(fontSize: 14),
                    )
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    "可用库存: ${data['QTYCAN']}",
                  ),
                  Text(
                    "在单: ${data['QTYPREOUT']}",
                  ),
                  Text(
                    "在途: ${data['QTYPREIN']}",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
