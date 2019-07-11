import 'package:flutter/material.dart';
import 'package:jpda/pages/comm/base/query_where.dart';

class PanDianPage extends StatefulWidget {
  @override
  _PanDianPageState createState() => _PanDianPageState();
}

class _PanDianPageState extends State<PanDianPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("盘点"),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
              color: Theme.of(context).primaryIconTheme.color,
            ),
            onPressed: () async {
              var rets = await Navigator.of(context).pushNamed("/stock/query",
                  arguments: QueryPageDataBuilder(),
              );
              if (rets == null) {
                return;
              }
//              var m = rets as Map;
//              Map p = {};
//              p[ProductKey] = formatDataValue(rets, ProductKey);
//              p[StoreKey] = formatDataValue(rets, StoreKey);
//              p[SkuKey] = formatDataValue(rets, SkuKey);
//              _param = p;
//              reLoadData();
            },
            tooltip: "查询",
          ),
        ],
      ),
    );
  }
}
