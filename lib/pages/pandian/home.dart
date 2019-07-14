import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jpda/comm/func.dart';
import 'package:jpda/comm/jpda.dart';
import 'package:jpda/pages/comm/base/query_where.dart';
import 'package:jpda/pages/comm/weigets/loading_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PanDianPage extends StatefulWidget {
  @override
  _PanDianPageState createState() => _PanDianPageState();
}

class _PanDianPageState extends State<PanDianPage> {
  static final DocnoKey = "docno";
  static final BilldateKey = "billdate";
  static final StatusKey = "status";
  static final StoreKey = "store";
  static final DoctypeKey = "doctype";
  static final IsActiveKey = 'isactive';

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

  @override
  Widget build(BuildContext context) {
//    print(_datas);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("盘点"),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
            ),
            onPressed: _openQueryPage,
            tooltip: "查询",
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed("/pandian/new");
        },
        child: Icon(Icons.add),
      ),
      body: LoadingWidget(
        loading: _loading,
        child: _buildItems(context),
      ),
    );
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
          return PanDianItemWidget(
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

  Future<void> _openQueryPage() async {
    var rets = await Navigator.of(context).pushNamed("/stock/query",
        arguments: QueryPageDataBuilder()
          ..add(DocnoKey, "单据编号", QueryPageDataBuilder.QUERY_ITEM_INPUT)
          ..add(BilldateKey, "单据日期",
              QueryPageDataBuilder.QUERY_ITEM_DATE_RANGE_PICKER)
          ..add(StoreKey, "盘点店仓", QueryPageDataBuilder.QUERY_ITEM_INPUT_QUERY,
              data: {"path": "/comm/query/store"})
          ..add(DoctypeKey, "单据类型", QueryPageDataBuilder.QUERY_ITEM_SELECT,
              data: {
                "items": [
                  {"name": "全部", "val": "All"},
                  {"name": "全盘", "val": "INF"},
                  {"name": "随机盘点", "val": "INR"},
                  {"name": "历史盘点", "val": "INH"},
                  {"name": "抽盘", "val": "INS"},
                  {"name": "历史抽盘", "val": "IHS"},
                ],
                "default": "All"
              })
          ..add(StatusKey, "单据状态", QueryPageDataBuilder.QUERY_ITEM_SELECT,
              data: {
                "items": [
                  {"name": "全部", "val": 100},
                  {"name": "未提交", "val": 1},
                  {"name": "提交", "val": 2},
                ],
                "default": 1,
              }));
    if (rets == null) {
      return;
    }
    _param = rets as Map;
    reLoadData();
  }

  Future<void> reLoadData() async {
    try {
      _loading = true;
      _page = 1;
      _param["page"] = _page;
      _datas = [];
      Response<Map> da =
          await JPda.web.query(context, "jpda_pandian\$list", _param);
      List dd = json.decode(da.data["data"]);
      List<Map> d = dd.map((f) => f as Map).toList();
      if (d.length > 0) {
        _datas.addAll(d);
        _page++;
      }
    } catch (e) {
      print(e);
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
          await JPda.web.query(context, "jpda_pandian\$list", _param);
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
      setState(() {
        _refreshController.loadFailed();
      });
    }
  }
}

class PanDianItemWidget extends StatelessWidget {
  final Map data;

  const PanDianItemWidget({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Text(
                        "${data['DOCNO']}",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    Text(
                      "${data['STATUS'] == 2 ? '提交' : '未提交'}",
                      style: TextStyle(
                          color: data['STATUS'] == 2
                              ? Colors.redAccent
                              : Colors.green),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                "${data['STORENAME']}",
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            Text(
                              "${data['BILLDATE']}",
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  text: "备注：${data['REMARK']}",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                '${data['DOCTYPENAME']}',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                height: 1,
              ),
              SizedBox(
                height: 6,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "行:${data['TOT_LINES']},账:${data['TOT_QTYBOOK']},实:${data['TOT_QTYCOUNT']}",
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                  InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed("/pandian/detail",
                            arguments: {"id": data['ID']});
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                                color: Theme.of(context).dividerColor)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6.0),
                        child: Text("查看"),
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
