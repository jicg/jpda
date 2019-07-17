import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jpda/comm/func.dart';
import 'package:jpda/comm/jpda.dart';
import 'package:jpda/pages/comm/weigets/search_inputfeild.dart';
import 'package:jpda/pages/comm/weigets/loading_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:cached_network_image/cached_network_image.dart';

class QueryBaseWidget extends StatefulWidget {
  final QueryBeanDelegate delegate;

  const QueryBaseWidget({Key key, @required this.delegate}) : super(key: key);

  @override
  _QueryBaseWidgetState createState() => _QueryBaseWidgetState();
}

class _QueryBaseWidgetState extends State<QueryBaseWidget> {
  RefreshController _refreshController;
  bool _single = false;
  Map _arguments = {};

  Map<int, Map> datas = {};
  List<int> keys = [];

  List<int> selKeys = [];
  bool _loading = false;
  int _page = 1;
  String _query = "";

  bool _showBottomBtns = true;

  @override
  void initState() {
    loadParams();
    reLoadData();
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void loadParams() {
    Future.delayed(Duration.zero, () {
      setState(() {
        _arguments = ModalRoute.of(context).settings.arguments;
        if(_arguments !=null) {
          _single = _arguments['single'] == true;
          _showBottomBtns = !_single;
        }
      });
    });
  }

  Future<void> reLoadData() async {
    try {
      _loading = true;
      _page = 1;
      keys = [];
      Response<Map> da = await widget.delegate.query(context, _query, _page);
      List dd = json.decode(da.data["data"]);
      dd.forEach((f) {
        Map ff = f as Map;
        int id = ff["id"] as int;
        if (!this.keys.contains(id)) {
          this.keys.add(id);
        }
        datas[id] = ff;
        //return ff;
      }); //.toList();
      if (dd.length > 0) {
        _page++;
      }
    }
//    on NotLoginException {
//      UIUtils.ToaskError("请先登录");
//      Navigator.of(context).pushNamed("/login");
//    }

    catch (e) {
      UIUtils.toaskError("$e");
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> loadMoreData() async {
    try {
      Response<Map> da = await widget.delegate.query(context, _query, _page);
      List dd = json.decode(da.data["data"]);
      dd.forEach((f) {
        Map ff = f as Map;
        int id = ff["id"] as int;
        if (!this.keys.contains(id)) {
          this.keys.add(id);
        }
        datas[id] = ff;
      });
      if (dd.length > 0) {
        _page++;
//        datas.addAll(dm);
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

  void query(value) {
    _query = value;
    reLoadData();
  }

  void _showModalBottomSheet(BuildContext context) {

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
                        child: Stack(
                          children: <Widget>[
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "已经选择",
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                                )),
                            Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  onTap: () {
                                    state(() {
                                      selKeys.clear();
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "清除",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                            itemBuilder: (context, i) {
                              final int id = selKeys[i];
                              final Map map = datas[id];
                              return widget.delegate.buildBootItem(context, map,
                                  () {
                                state(() {
                                  selKeys.remove(id);
                                });
                              });
                            },
                            separatorBuilder: (context, i) {
                              return new Divider(
                                height: 0,
                              );
                            },
                            itemCount: selKeys.length),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }).whenComplete(() {
      setState(() {
//        _showBottomBtns = true;
      });
    });
  }

  Widget _buildBottomBtns(BuildContext context) {
    return Container(
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
                  Navigator.of(context).pop(selKeys.map((f) {
                    return datas[f];
                  }).toList());
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.delegate.title),
        centerTitle: true,
        actions: _single ? []
            : <Widget>[
                InkWell(
                  onTap: () => _showModalBottomSheet(context),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16),
                      child: Text(
                        "${selKeys.length}",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                )
              ],
      ),
      body: Column(
        children: <Widget>[
          SearchInputFeild(
            hintText: widget.delegate.hintText,
            query: query,
          ),
          Expanded(
              child:
                  LoadingWidget(loading: _loading, child: _buildQueryData())),
          Visibility(
              visible: _showBottomBtns, child: _buildBottomBtns(context)),
        ],
      ),
    );
  }

  Widget _buildQueryData() {
    if (keys.length == 0) {
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
          final int id = keys[i];
          final Map map = datas[id];
          return widget.delegate
              .buildItem(context, map, this.selKeys.contains(id), () {
            setState(() {
              if (_single) {
                Navigator.pop(context, map);
                return;
              }
              if (this.selKeys.contains(id)) {
                this.selKeys.remove(id);
              } else {
                this.selKeys.add(id);
              }
            });
          });
        },
        separatorBuilder: (context, i) {
          return Divider(
            height: 0,
          );
        },
        itemCount: keys.length,
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
