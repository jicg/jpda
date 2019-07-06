
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jpda/comm/jpda.dart';
import 'package:jpda/pages/comm/base/query_comm.dart';

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
  Future<Response<Map>> query(BuildContext context,String query, int page) {
    return JPda.web
        .query(context,"jpda_comm\$query_product", {"page": page, "query": query});
  }

  @override
  // TODO: implement hintText
  String get hintText => "条码/款号编号/款号名称";

  @override
  // TODO: implement title
  String get title => "商品查询";
}
//class QueryProductPage extends StatefulWidget {
//  @override
//  _QueryProductPageState createState() => _QueryProductPageState();
//}
//
//class _QueryProductPageState extends State<QueryProductPage> {
//  RefreshController _refreshController;
//  List<Map> datas = [];
//  bool _loading = false;
//  int _page = 1;
//  String _query = "";
//  final String func = "jpda_comm\$query_product";
//
//  @override
//  void initState() {
//    reLoadData();
//    super.initState();
//    _refreshController = RefreshController(initialRefresh: false);
//  }
//
//  @override
//  void dispose() {
//    _refreshController.dispose();
//    super.dispose();
//  }
//
//  Future<void> reLoadData() async {
//    try {
//      _loading = true;
//      datas = [];
//      _page = 1;
//      Response<Map> da =
//          await JPda.web.query(func, {"page": _page, "query": _query});
//      List dd = json.decode(da.data["data"]);
//      List<Map> dm = dd.map((f) {
//        return f as Map;
//      }).toList();
//      if (dm.length > 0) {
//        _page++;
//        datas.addAll(dm);
//      }
//    } catch (e) {
//      UIUtils.ToaskError("$e");
//    }
//    setState(() {
//      _loading = false;
//    });
//  }
//
//  Future<void> loadMoreData() async {
//    try {
//      Response<Map> da =
//          await JPda.web.query(func, {"page": _page, "query": _query});
//      List dd = json.decode(da.data["data"]);
//      List<Map> dm = dd.map((f) {
//        return f as Map;
//      }).toList();
//      if (dm.length > 0) {
//        _page++;
//        datas.addAll(dm);
//        setState(() {
//          _refreshController.loadComplete();
//        });
//      } else {
//        UIUtils.ToaskError("已经没有数据");
//        setState(() {
//          _refreshController.loadNoData();
//        });
//      }
//    } catch (e) {
//      UIUtils.ToaskError("$e");
//      setState(() {
//        _refreshController.loadFailed();
//      });
//    }
//  }
//
//  void query(value) {
//    _query = value;
//    reLoadData();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: Text("查询商品"),
//        centerTitle: true,
//      ),
//      body: Column(
//        children: <Widget>[
//          InputScanSearch(
//            query: query,
//          ),
//          Expanded(
//              child:
//                  LoadingWidget(loading: _loading, child: _buildQueryData())),
//          Container(
//            padding: EdgeInsets.all(0),
//            decoration: BoxDecoration(
//                color: Colors.white,
//                boxShadow: [
//                  new BoxShadow(
//                      blurRadius: 20.0,
//                      offset: new Offset(1.0, 3.0),
//                      spreadRadius: 1.0)
//                ],
//                border: Border.all(color: Theme.of(context).dividerColor)),
//            child: Row(
//              mainAxisSize: MainAxisSize.min,
//              children: <Widget>[
//                SizedBox(
//                  width: 10,
//                ),
//                Expanded(
//                  child: RaisedButton.icon(
//                      onPressed: () {},
//                      icon: Icon(Icons.cancel),
//                      label: Text("取消")),
//                ),
//                SizedBox(
//                  width: 10,
//                ),
//                Expanded(
//                  child: RaisedButton.icon(
//                      onPressed: () {},
//                      color: Colors.blue,
//                      icon: Icon(Icons.done, color: Colors.white),
//                      label: Text(
//                        "确定",
//                        style: TextStyle(color: Colors.white),
//                      )),
//                ),
//                SizedBox(
//                  width: 10,
//                ),
//              ],
//            ),
//          )
//        ],
//      ),
//    );
//  }
//
//  Widget _buildQueryData() {
//    if (datas.length == 0) {
//      return new Container(
//        child: Center(
//          child: Text("没有数据"),
//        ),
//      );
//    }
//    return SmartRefresher(
//      controller: _refreshController,
//      child: ListView.separated(
//        itemBuilder: (context, i) {
//          return new ListTile(
//            leading: datas[i]['img'] != null
//                ? Container(
//                    color: Colors.blue,
//                    width: 40,
//                    height: 40,
//                    child: Center(
//                      child: Image.network(
//                        JPda.web.baseUrl + datas[i]['img'],
//                      ),
//                    ),
//                  )
//                : null,
//            title: Text("${datas[i]['code']}"),
//            subtitle: Text("${datas[i]['name']} ${datas[i]['desc']}"),
//          );
//        },
//        separatorBuilder: (context, i) {
//          return Divider(
//            height: 0,
//          );
//        },
//        itemCount: datas.length,
//      ),
//      enablePullDown: false,
//      enablePullUp: true,
//      onLoading: () async {
//        await loadMoreData();
//      },
//    );
//  }
//}
