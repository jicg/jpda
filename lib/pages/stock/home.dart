import 'package:flutter/material.dart';
import 'package:jpda/comm/jpda.dart';
import 'package:jpda/pages/comm/base/query_where.dart';

class StockHome extends StatefulWidget {
  @override
  _StockHomeState createState() => _StockHomeState();
}

class _StockHomeState extends State<StockHome> {
  static const ProductKey = "product";
  static const StoreKey = "store";
  static const RemarkKey = "remark";

  Map _param = {};
  int _page = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
                      ..add(ProductKey, "商品",
                          QueryPageDataBuilder.QUERY_ITEM_INPUT_QUERY,
                          data: {"path": "/comm/query/product"})
                      ..add(StoreKey, "店仓",
                          QueryPageDataBuilder.QUERY_ITEM_INPUT_QUERY,
                          data: {"path": "/comm/query/store"})
                      ..add(RemarkKey, "备注",
                          QueryPageDataBuilder.QUERY_ITEM_INPUT));
                if (rets == null) {
                  return;
                }
                var m = rets as Map;
                Map p = {};
                p[ProductKey] = formatDataValue(rets, ProductKey);
                p[StoreKey] = formatDataValue(rets, StoreKey);
                p[RemarkKey] = formatDataValue(rets, RemarkKey);
                query(p);
              },
              tooltip: "查询",
            ),
          ],
        ),
        body: Container(
          child: StockItemWidget(),
        ));
  }

  void query(Map param) async {
    try {
      param["page"] = _page;
      var r = await JPda.web.query(context, "jpda_stock\$list", param);
      print(r);
    } catch (e) {
      print(e);
    }
  }

  Map formatDataValue(Map rets, String key) {
    Map p = {};
    if (rets[ProductKey] is List) {
      p["list"] = rets[ProductKey];
    } else {
      p["text"] = rets[ProductKey];
    }
    return p;
  }
}

class StockItemWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
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
                    "店仓",
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    "条码",
                    style: TextStyle(fontSize: 14),
                  )
                ],
              ),
            ),
            Text(
              "100",
              style: TextStyle(fontSize: 28),
            ),
          ],
        ),
      ),
    );
  }
}
