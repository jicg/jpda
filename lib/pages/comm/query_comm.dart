import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jpda/comm/func.dart';
import 'package:jpda/comm/jpda.dart';
import 'package:jpda/comm/widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:jpda/comm/exception.dart';

class QueryBaseWidget extends StatefulWidget {
  final QueryBeanDelegate delegate;

  const QueryBaseWidget({Key key, @required this.delegate}) : super(key: key);

  @override
  _QueryBaseWidgetState createState() => _QueryBaseWidgetState();
}

class _QueryBaseWidgetState extends State<QueryBaseWidget> {
  RefreshController _refreshController;
  List<Map> datas = [];
  List<Map> selDatas = [];
  bool _loading = false;
  int _page = 1;
  String _query = "";

  @override
  void initState() {
    reLoadData();
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> reLoadData() async {
    try {
      _loading = true;
      datas = [];
      _page = 1;
      Response<Map> da = await widget.delegate.query(context, _query, _page);
      List dd = json.decode(da.data["data"]);
      List<Map> dm = dd.map((f) {
        return f as Map;
      }).toList();
      if (dm.length > 0) {
        _page++;
        datas.addAll(dm);
      }
    }
//    on NotLoginException {
//      UIUtils.ToaskError("请先登录");
//      Navigator.of(context).pushNamed("/login");
//    }

    catch (e) {
      UIUtils.ToaskError("$e");
    }
    setState(() {
      _loading = false;
    });
  }

  Map getParam() {}

  Future<void> loadMoreData() async {
    try {
      Response<Map> da = await widget.delegate.query(context, _query, _page);
      List dd = json.decode(da.data["data"]);
      List<Map> dm = dd.map((f) {
        return f as Map;
      }).toList();
      if (dm.length > 0) {
        _page++;
        datas.addAll(dm);
        setState(() {
          _refreshController.loadComplete();
        });
      } else {
        UIUtils.ToaskError("已经没有数据");
        setState(() {
          _refreshController.loadNoData();
        });
      }
    }
//    on NotLoginException {
//      UIUtils.ToaskError("请先登录");
//      setState(() {
//        _refreshController.loadFailed();
//      });
//      Navigator.of(context).pushNamed("/login");
//    }
    catch (e) {
      UIUtils.ToaskError("$e");
      setState(() {
        _refreshController.loadFailed();
      });
    }
  }

  void query(value) {
    _query = value;
    reLoadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.delegate.title),
        centerTitle: true,
        actions: <Widget>[
          InkWell(
            onTap: () {
              showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (BuildContext context, state) {
                        return InkWell(
                          onTap: () {},
                          child: Container(
                            color: Colors.white,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  color: Colors.blue,
                                  padding: EdgeInsets.all(8),
                                  child: Stack(
                                    children: <Widget>[
                                      Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "已经选择",
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white),
                                          )),
                                      InkWell(
                                        onTap: () {
                                          state(() {
                                            selDatas.clear();
                                          });

                                        },
                                        child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              "清除",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: ListView.separated(
                                      itemBuilder: (context, i) {
                                        final Map map = selDatas[i];
                                        return widget.delegate
                                            .buildBootItem(context, map, () {
                                          state(() {
                                            selDatas.remove(map);
                                          });
                                        });
                                      },
                                      separatorBuilder: (context, i) {
                                        return new Divider(
                                          height: 0,
                                        );
                                      },
                                      itemCount: selDatas.length),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }).whenComplete(() {
                setState(() {});
              });
            },
            child: Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                child: Text(
                  "${selDatas.length}",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          InputScanSearch(
            hintText: widget.delegate.hintText,
            query: query,
          ),
          Expanded(
              child:
                  LoadingWidget(loading: _loading, child: _buildQueryData())),
          Container(
            padding: EdgeInsets.all(0),
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  new BoxShadow(
                      blurRadius: 20.0,
                      offset: new Offset(1.0, 3.0),
                      spreadRadius: 1.0)
                ],
                border: Border.all(color: Theme.of(context).dividerColor)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: RaisedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.cancel),
                      label: Text("取消")),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: RaisedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop(selDatas);
                      },
                      color: Colors.blue,
                      icon: Icon(Icons.done, color: Colors.white),
                      label: Text(
                        "确定",
                        style: TextStyle(color: Colors.white),
                      )),
                ),
                SizedBox(
                  width: 10,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQueryData() {
    if (datas.length == 0) {
      return new Container(
        child: Center(
          child: Text("没有数据"),
        ),
      );
    }
    return SmartRefresher(
      controller: _refreshController,
      child: ListView.separated(
        itemBuilder: (context, i) {
          final Map map = datas[i];
          return widget.delegate
              .buildItem(context, map, this.selDatas.contains(map), () {
            setState(() {
              if (this.selDatas.contains(map)) {
                this.selDatas.remove(map);
              } else {
                this.selDatas.add(map);
              }
            });
          });
        },
        separatorBuilder: (context, i) {
          return Divider(
            height: 0,
          );
        },
        itemCount: datas.length,
      ),
      enablePullDown: false,
      enablePullUp: true,
      onLoading: () async {
        await loadMoreData();
      },
    );
  }
}

abstract class QueryBeanDelegate {
  String get title;

  String get hintText;

  Future<Response<Map>> query(BuildContext context, String query, int page);

  Widget buildItem(
      BuildContext context, final Map map, bool selected, VoidCallback onTap) {
    return new ListTile(
      leading: map['img'] != null
          ? Container(
              width: 40,
              height: 40,
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: JPda.web.baseUrl + map['img'],
                  placeholder: (c, u) => new CircularProgressIndicator(),
                  errorWidget: (context, url, error) => new Icon(Icons.error),
                ),
              ),
            )
          : null,
      title: Text("${map['code']} "),
      subtitle: Text("${map['name']} ${map['desc']}"),
      trailing: selected ? Icon(Icons.done) : null,
      onTap: onTap,
    );
  }

  Widget buildBootItem(
      BuildContext context, final Map map, VoidCallback onTap) {
    return new ListTile(
      leading: map['img'] != null
          ? Container(
              width: 40,
              height: 40,
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: JPda.web.baseUrl + map['img'],
                  placeholder: (c, u) => new CircularProgressIndicator(),
                  errorWidget: (context, url, error) => new Icon(Icons.error),
                ),
              ),
            )
          : null,
      title: Text("${map['code']} "),
      subtitle: Text("${map['name']} ${map['desc']}"),
      trailing: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Icon(Icons.delete),
          )),
    );
  }
}